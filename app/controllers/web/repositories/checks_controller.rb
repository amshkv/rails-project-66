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

  def get_linter_errors(check)
    # NOTE: такой тупой иф, потому что в фикстурах хекслет чека нет этого поля (а должно бы быть :yuy_suka:)
    json = JSON.parse(check.lint_messages.presence || '{}')
    Rails.cache.fetch(check.cache_key_with_version, expires_in: 12.hours) do
      "#{check.repository.language}LintingService".classify.constantize.serialize_errors(json)
    end
  end
end
