# frozen_string_literal: true

require 'test_helper'

class Web::RepositoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:base)
  end

  test 'guest cant get index' do
    get repositories_url
    assert_redirected_to root_url
  end

  test 'guest cant get new' do
    get new_repository_url
    assert_redirected_to root_url
  end

  test 'signed user can get index' do
    sign_in(@user)
    get repositories_url
    assert_response :success
  end

  test 'signed user can get new' do
    sign_in(@user)
    get new_repository_url
    assert_response :success
  end
end
