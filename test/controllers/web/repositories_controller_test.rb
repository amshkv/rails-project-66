# frozen_string_literal: true

require 'test_helper'

class Web::RepositoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:base)
    @repository = repositories(:base)
    @attrs = {
      github_id: 63_350_547
    }
  end

  test 'guest cant get index' do
    get repositories_path
    assert_redirected_to root_path
  end

  test 'guest cant get new' do
    get new_repository_path
    assert_redirected_to root_path
  end

  test 'signed user get index' do
    sign_in(@user)
    get repositories_path
    assert_response :success
  end

  test 'signed user get new' do
    sign_in(@user)

    get new_repository_path
    assert_response :success
  end

  test 'signed user get show' do
    sign_in(@user)

    get repository_path(@repository)
    assert_response :success
  end

  test 'guest cant create repo' do
    post repositories_path, params: { repository: @attrs }
    assert_redirected_to root_path
  end

  test 'signed user create repo' do
    sign_in(@user)

    post repositories_path, params: { repository: @attrs }

    repo = Repository.find_by @attrs

    assert { repo }
    assert { repo.fetched? }
    assert { repo.name.present? }
    assert_redirected_to repositories_path
  end
end
