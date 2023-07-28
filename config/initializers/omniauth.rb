# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  # TODO: NOT HEXLET WAY FETCH WITH NIL
  provider :github, ENV.fetch('GITHUB_CLIENT_ID', nil), ENV.fetch('GITHUB_CLIENT_SECRET', nil), scope: 'user,public_repo,admin:repo_hook'
end
