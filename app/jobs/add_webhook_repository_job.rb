# frozen_string_literal: true

class AddWebhookRepositoryJob < ApplicationJob
  queue_as :default

  def perform(repo_id)
    repo = Repository.find repo_id
    token = repo.user.token
    github_id = repo.github_id.to_i

    client = api_client(token)

    return if hook_exists?(github_id, token)

    client.create_hook(
      github_id,
      'web',
      {
        url: Rails.application.routes.url_helpers.api_checks_url,
        content_type: 'json'
      },
      {
        events: ['push'],
        active: true
      }
    )
  end

  private

  def api_client(token)
    ApplicationContainer[:octokit].new access_token: token, auto_paginate: true
  end

  def hooks(github_id, token)
    client = api_client(token)
    client.hooks(github_id)
  end

  def hook_exists?(github_id, token)
    hooks(github_id, token).any? do |hook|
      hook['config']['url'] == Rails.application.routes.url_helpers.api_checks_url
    end
  end
end
