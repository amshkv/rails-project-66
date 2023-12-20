# frozen_string_literal: true

class RepositoryCheckJob < ApplicationJob
  queue_as :default

  def perform(check_id)
    check = Repository::Check.find check_id
    github_id = check.repository.github_id.to_i

    client = ApplicationContainer[:octokit].new
    github_data = client.repo(github_id)
    clone_url = github_data['clone_url']
    commits = client.commits(github_id)
    last_commit_id = commits[0]['sha']
    commit_id = last_commit_id[0..6]

    repo_dir = File.join('tmp', 'repos', check_id.to_s)

    clone_exit_status = ApplicationContainer[:repository_check_utils].clone_repository(clone_url, repo_dir)

    unless clone_exit_status.zero?
      raise StandardError
    end

    lint_command = "npx eslint #{repo_dir} -f json"

    lint_errors, lint_exit_status = ApplicationContainer[:repository_check_utils].start_lint_command(lint_command)

    # NOTE: тут падает, если JSON не валидный, падает на parse
    lint_messages_count = sum_lint_messages(JSON.parse(lint_errors))

    check.update!(
      commit_id:,
      success_check: lint_exit_status.zero?, # NOTE: возможно тут надо ориентироваться на кол-во ошибок линтера еще?
      lint_messages: lint_errors,
      lint_messages_count:
    )

    check.mark_as_finish!
    ApplicationContainer[:repository_check_utils].remove_repository_dir(repo_dir)
  rescue StandardError => e
    Rails.logger.debug e.inspect
    check.mark_as_failed!
    ApplicationContainer[:repository_check_utils].remove_repository_dir(repo_dir)
  end

  def sum_lint_messages(json)
    json.pluck('errorCount').sum
  end
end
