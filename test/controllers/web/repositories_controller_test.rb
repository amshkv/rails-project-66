# frozen_string_literal: true

require 'test_helper'

class Web::RepositoriesControllerTest < ActionDispatch::IntegrationTest
  test 'get index' do
    get repositories_url
    assert_response :success
  end

  test 'get new' do
    get new_repository_url
    assert_response :success
  end
end
