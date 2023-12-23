# frozen_string_literal: true

class FetchUserRepositoryInfoJob < ApplicationJob
  queue_as :default

  def perform(repo_id)
    repository = Repository.find repo_id
    github_id = repository.github_id.to_i
    token = repository.user.token

    repository.fetch!

    client = ApplicationContainer[:octokit].new access_token: token, auto_paginate: true
    github_data = client.repo(github_id)

    repository.update!(
      full_name: github_data['full_name'],
      git_url: github_data['git_url'],
      language: github_data['language'].downcase,
      name: github_data['name'],
      ssh_url: github_data['ssh_url'],
      clone_url: github_data['clone_url']
    )

    repository.mark_as_fetched!
  rescue StandardError => e
    repository&.mark_as_failed!
    Rails.logger.error("#{e.class}: #{e.message}")
    Sentry.capture_exception(e)
  end
end
