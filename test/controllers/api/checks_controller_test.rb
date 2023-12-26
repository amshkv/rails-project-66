# frozen_string_literal: true

require 'test_helper'

class Api::ChecksControllerTest < ActionDispatch::IntegrationTest
  test 'api check create' do
    repository = repositories(:without_checks)

    payload = {
      'repository' => {
        'id' => repository.github_id
      }
    }

    post api_checks_path, as: :json, headers: { 'x-github-event': 'push' }, params: payload

    assert_response :ok

    check = Repository::Check.find_by repository: repository.id

    assert { check }
    assert { check.finished? }
    assert { check.passed }
  end
end
