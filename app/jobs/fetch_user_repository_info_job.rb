# frozen_string_literal: true

require 'octokit'

class FetchUserRepositoryInfoJob < ApplicationJob
  queue_as :default

  def perform(repo_id)
    repository = Repository.find repo_id
    github_id = repository.github_id.to_i
    client = Octokit::Client.new
    github_data = client.repo(github_id)

    repository.update!(
      full_name: github_data.full_name,
      git_url: github_data.git_url,
      language: github_data.language.downcase,
      name: github_data.name,
      ssh_url: github_data.ssh_url
    )
  end
end
