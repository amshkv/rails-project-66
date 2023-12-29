# frozen_string_literal: true

class RepositoryCheckJob < ApplicationJob
  queue_as :default

  def perform(check_id)
    check = Repository::Check.find check_id

    check.mark_as_started!

    repository = check.repository
    repo_data = repository_data(repository)

    language = repo_data[:language]
    clone_url = repo_data[:clone_url]

    repo_dir = File.join('tmp', 'repos', check_id.to_s)

    clone_exit_status = ApplicationContainer[:repository_check_utils].clone_repository(clone_url, repo_dir)

    unless clone_exit_status.zero?
      raise StandardError
    end

    commit_id = ApplicationContainer[:repository_check_utils].get_last_commit_id(repo_dir)

    linting_service = "#{language}LintingService".classify.constantize

    lint_command = linting_service.start_command(repo_dir)

    lint_errors, = ApplicationContainer[:repository_check_utils].start_lint_command(lint_command)

    parsed_json = JSON.parse(lint_errors)
    lint_messages_count = linting_service.lint_messages_count(parsed_json)

    check.update!(
      commit_id:,
      passed: lint_messages_count.zero?, # NOTE: до этого проверка была на exit_status, но кажется правильнее проверять что нет ошибок
      lint_messages: lint_errors,
      lint_messages_count:
    )
    check.mark_as_finish!
  rescue StandardError => e
    check&.mark_as_failed!
    Rails.logger.error("#{e.class}: #{e.message}")
    Sentry.capture_exception(e)
  ensure
    RepositoryCheckMailer.with(check:).failed_check.deliver_later if check.failed? || !check.passed
    ApplicationContainer[:repository_check_utils].remove_repository_dir(repo_dir)
  end

  private

  def repository_data(repository)
    if repository.fetched?
      {
        clone_url: repository.clone_url,
        language: repository.language
      }
    else
      token = repository.user.token
      client = ApplicationContainer[:octokit].new access_token: token, auto_paginate: true
      github_id = repository.github_id.to_i
      github_data = client.repo(github_id)

      {
        clone_url: github_data['clone_url'],
        language: github_data['language'].downcase.to_sym
      }
    end
  end
end
