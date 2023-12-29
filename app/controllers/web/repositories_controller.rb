# frozen_string_literal: true

require 'octokit'

class Web::RepositoriesController < Web::ApplicationController
  before_action :authenticate_user

  def index
    @repositories = current_user.repositories.includes([:checks])
  end

  def show
    @repository = current_user.repositories.find(params[:id])
    @checks = @repository.checks.order(id: :desc)
  end

  def new
    @repositories = repos_with_allowed_languages.map { |repo| [repo['full_name'], repo['id']] }

    @repository = current_user.repositories.new
  end

  def create
    @repository = current_user.repositories.find_or_initialize_by(permitted_params)

    if @repository.save
      FetchUserRepositoryInfoJob.perform_later(@repository.id)
      AddWebhookRepository.perform_later(@repository.id)
      redirect_to repositories_path, notice: I18n.t('repository.create.success')
    else
      @repositories = repos_with_allowed_languages.map { |repo| [repo['full_name'], repo['id']] }
      flash.now[:alert] = I18n.t('repository.create.failure')
      render :new, status: :unprocessable_entity
    end
  end

  private

  def permitted_params
    params.require(:repository).permit(:github_id)
  end

  def user_repositories
    Rails.cache.fetch("#{current_user.cache_key_with_version}/user_repositories", expires_in: 12.hours) do
      client = ApplicationContainer[:octokit].new access_token: current_user.token, auto_paginate: true
      client.repos
    end
  end

  def repos_with_allowed_languages
    user_repositories.filter { |repo| Repository.language.value? repo['language']&.downcase }
  end
end
