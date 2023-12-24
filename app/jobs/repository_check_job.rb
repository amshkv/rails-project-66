# frozen_string_literal: true

class RepositoryCheckJob < ApplicationJob
  queue_as :default

  def perform(check_id)
    check = Repository::Check.find check_id
    repository = check.repository

    language, clone_url, commit_id = repository_data(repository)

    repo_dir = File.join('tmp', 'repos', check_id.to_s)

    clone_exit_status = ApplicationContainer[:repository_check_utils].clone_repository(clone_url, repo_dir)

    unless clone_exit_status.zero?
      raise StandardError
    end

    lint_commands_by_languages = {
      ruby: "bundle exec rubocop #{repo_dir} --format json",
      javascript: "npx eslint #{repo_dir} -f json --no-eslintrc"
    }

    lint_command = lint_commands_by_languages[language]

    lint_errors, lint_exit_status = ApplicationContainer[:repository_check_utils].start_lint_command(lint_command)

    # NOTE: тут падает, если JSON не валидный, падает на parse
    parsed_json = JSON.parse(lint_errors)
    lint_messages_count = language == :ruby ? sum_lint_messages_on_ruby(parsed_json) : sum_lint_messages_on_javascript(parsed_json)

    check.update!(
      commit_id:,
      passed: lint_exit_status.zero?, # NOTE: возможно тут надо ориентироваться на кол-во ошибок линтера еще?
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

  def sum_lint_messages_on_javascript(json)
    json.pluck('errorCount').sum
  end

  def sum_lint_messages_on_ruby(json)
    json['summary']['offense_count']
  end

  def repository_data(repository)
    token = repository.user.token
    client = ApplicationContainer[:octokit].new access_token: token, auto_paginate: true

    github_id = repository.github_id.to_i

    github_data = client.repo(github_id)
    clone_url = github_data['clone_url']
    language = github_data['language'].downcase.to_sym

    commits = client.commits(github_id) # NOTE: как получить всё остальное понятно, а вот как получить коммиты, из БД?

    last_commit_id = commits[0]['sha']
    commit_id = last_commit_id[0..6]

    [language, clone_url, commit_id]
  end
end
