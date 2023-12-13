# frozen_string_literal: true

class Web::Repositories::ChecksController < Web::Repositories::ApplicationController
  after_action :verify_authorized, only: %i[create show]

  def show
    @check = Repository::Check.find params[:id]
    authorize @check
  end

  def create
    repository = Repository.find(params[:repository_id])
    check = repository.checks.new

    authorize check

    if check.save
      redirect_to repository_path(repository), notice: I18n.t('repository.check.create.success')
    else
      redirect_to repository_path(repository), alert: check.errors.full_messages.join(', ')
    end
  end
end
