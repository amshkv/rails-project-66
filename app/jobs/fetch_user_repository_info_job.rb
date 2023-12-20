# frozen_string_literal: true

class FetchUserRepositoryInfoJob < ApplicationJob
  queue_as :default

  def perform(repo_id)
    repository = Repository.find repo_id
    github_id = repository.github_id.to_i

    repository.fetch!

    client = ApplicationContainer[:octokit].new
    github_data = client.repo(github_id)

    repository.update!(
      full_name: github_data['full_name'],
      git_url: github_data['git_url'],
      language: github_data['language'].downcase,
      name: github_data['name'],
      ssh_url: github_data['ssh_url']
    )

    repository.mark_as_fetched!
  rescue StandardError
    # NOTE: тут наверное можно обрабатывать ошибку, типа посылать в сентри или еще куда
    # и я не знаю кстати как отработает джоба, когда падает ошибка, в сайдкике вроде будет перезапуск, надо поизучтаь это
    repository.mark_as_failed!
  end
end
