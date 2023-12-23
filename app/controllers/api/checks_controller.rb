# frozen_string_literal: true

class Api::ChecksController < Api::ApplicationController
  def create
    event = request.headers['x-github-event']

    return head :ok if event != 'push'

    payload = JSON.parse(request.body.read)

    github_id = payload['repository']['id']

    repo = Repository.find_by(github_id:)

    return head :ok unless repo

    check = repo.checks.new
    return head :ok unless check.save

    RepositoryCheckJob.perform_later(check.id)

    head :ok
  end
end
