# frozen_string_literal: true

class ApplicationContainer
  extend Dry::Container::Mixin

  if Rails.env.test?
    register :octokit, -> { OctokitClientStub }
    register :repository_check_utils, -> { RepositoryCheckUtilsStub }
  else
    register :octokit, -> { Octokit::Client }
    register :repository_check_utils, -> { RepositoryCheckUtils }
  end
end
