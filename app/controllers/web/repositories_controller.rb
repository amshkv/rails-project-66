# frozen_string_literal: true

require 'octokit'

class Web::RepositoriesController < Web::ApplicationController
  before_action :authenticate_user!

  def index
    @repositories = current_user.repositories
  end

  def new
    client = Octokit::Client.new access_token: current_user.token, auto_paginate: true
    repos = client.repos
    filtered_repos = repos.filter { |repo| Repository.language.value? repo.language&.downcase }
    @repositories = filtered_repos.map { |repo| [repo.full_name, repo.id] }

    @repository = current_user.repositories.new
  end

  def create; end
end
