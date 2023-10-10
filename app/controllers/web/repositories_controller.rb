# frozen_string_literal: true

require 'octokit'

class Web::RepositoriesController < Web::ApplicationController
  before_action :authenticate_user!

  def index
    @repositories = current_user.repositories
  end

  def new
    filtered_repos = user_repositories.filter { |repo| Repository.language.value? repo.language&.downcase }
    @repositories = filtered_repos.map { |repo| [repo.full_name, repo.id] }

    @repository = current_user.repositories.new
  end

  def create
    @repository = current_user.repositories.find_or_initialize_by(permitted_params)
    repo = user_repositories.find { |r| r.id == @repository.github_id.to_i }

    if repo
      @repository.name = repo.name
      @repository.language = repo.language.downcase
    end

    if @repository.save
      redirect_to repositories_path, notice: I18n.t('repository.create.success')
    else
      redirect_to repositories_path, alert: @repository.errors.full_messages.join(', ')
    end
  end

  private

  def permitted_params
    params.require(:repository).permit(:github_id)
  end

  def get_user_repositories(user)
    Rails.cache.fetch("#{user.cache_key_with_version}/user_repositories", expires_in: 12.hours) do
      client = Octokit::Client.new access_token: user.token, auto_paginate: true
      client.repos
    end
  end

  def user_repositories
    get_user_repositories(current_user)
  end
end
