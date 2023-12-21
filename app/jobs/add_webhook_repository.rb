# frozen_string_literal: true

class AddWebhookRepository < ApplicationJob
  queue_as :default

  def perform(repo_id)
    repo = Repository.find repo_id
    token = repo.user.token
    client = ApplicationContainer[:octokit].new access_token: token, auto_paginate: true

    client.create_hook(
      repo.github_id.to_i,
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
end
