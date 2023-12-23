# frozen_string_literal: true

require 'test_helper'

class Api::ChecksControllerTest < ActionDispatch::IntegrationTest
  test 'api check create' do
    webhook_payload = File.read('test/fixtures/files/webhook_payload.json')
    repository = repositories(:without_checks)
    # NOTE: изобретаем фабрику?
    payload = JSON.parse(webhook_payload)

    payload['repository']['id'] = repository.github_id.to_i

    post api_checks_path, as: :json, headers: { 'x-github-event': 'push' }, params: payload

    assert_response :ok

    check = Repository::Check.find_by repository: repository.id

    assert { check }
    assert { check.finished? }
    assert { check.passed == false }
    assert { check.lint_messages_count == 4 }
  end
end
