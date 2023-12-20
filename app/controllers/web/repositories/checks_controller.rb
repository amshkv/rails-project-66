# frozen_string_literal: true

class Web::Repositories::ChecksController < Web::Repositories::ApplicationController
  after_action :verify_authorized, only: %i[create show]

  def show
    @check = Repository::Check.find params[:id]
    authorize @check

    redirect_to repository_path(@check.repository), notice: I18n.t("repository.check.state.#{@check.aasm_state}") and return unless @check.finished?

    @check_errors = get_linter_errors(@check)
  end

  def create
    repository = Repository.find(params[:repository_id])
    check = repository.checks.new

    authorize check

    if check.save
      RepositoryCheckJob.perform_later(check.id)
      redirect_to repository_path(repository), notice: I18n.t('repository.check.create.success')
    else
      redirect_to repository_path(repository), alert: check.errors.full_messages.join(', ')
    end
  end

  private

  # NOTE: тут падает, если JSON не валидный, падает на parse
  def get_linter_errors(check)
    json = JSON.parse(check.lint_messages)
    Rails.cache.fetch(check.cache_key_with_version, expires_in: 12.hours) do
      # NOTE: кажется лучше через when?
      check.repository.language == 'ruby' ? serialize_errors_ruby(json) : serialize_errors_javascript(json)
    end
  end

  def serialize_errors_javascript(json)
    json.map do |line|
      errors = line['messages'].map do |error|
        {
          message: error['message'],
          rule: error['ruleId'],
          position: "#{error['line']}:#{error['column']}"
        }
      end
      file_path = line['filePath']
      { file_path:, errors: }
    end
  end

  def serialize_errors_ruby(json)
    files = json['files']
    files_with_errors = files.filter { |file| file['offenses'].any? }
    files_with_errors.map do |file|
      errors = file['offenses'].map do |error|
        {
          message: error['message'],
          rule: error['cop_name'],
          position: "#{error['location']['line']}:#{error['location']['column']}"
        }
      end
      file_path = file['path']
      { file_path:, errors: }
    end
  end
end
