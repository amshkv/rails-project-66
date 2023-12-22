# frozen_string_literal: true

class Api::ChecksController < Api::ApplicationController
  def create
    event = request.headers['x-github-event']

    return if event != 'push'

    payload = JSON.parse(request.body.read)

    github_id = payload['repository']['id']

    repo = Repository.find_by(github_id:)

    return unless repo

    check = repo.checks.new
    return unless check.save

    RepositoryCheckJob.perform_later(check.id)
  end
end
