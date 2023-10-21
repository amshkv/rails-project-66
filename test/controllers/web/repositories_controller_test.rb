# frozen_string_literal: true

require 'test_helper'

class Web::RepositoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:base)
    @attrs = {
      github_id: 165_602_591 # TODO: как-то неудобно что тут я знаю id из json, это ок?
    }
  end

  test 'guest cant get index' do
    get repositories_url
    assert_redirected_to root_url
  end

  test 'guest cant get new' do
    get new_repository_url
    assert_redirected_to root_url
  end

  test 'signed user get index' do
    sign_in(@user)
    get repositories_url
    assert_response :success
  end

  test 'signed user get new' do
    sign_in(@user)

    stub_request(:get, 'https://api.github.com/user/repos?per_page=100')
      .to_return(
        status: 200,
        body: load_fixture('files/repositories_response.json'),
        headers: { 'Content-Type' => 'application/json' }
      )

    get new_repository_url
    assert_response :success
  end

  test 'guest cant create repo' do
    post repositories_url, params: { repository: @attrs }
    assert_redirected_to root_url
  end

  test 'signed user create repo' do
    sign_in(@user)
    stub_request(:get, 'https://api.github.com/repositories/165602591')
      .to_return(
        status: 200,
        body: load_fixture('files/repository_response.json'),
        headers: { 'Content-Type' => 'application/json' }
      )

    post repositories_url, params: { repository: @attrs }

    repo = Repository.find_by @attrs

    assert { repo }
    assert { repo.fetched? }
    assert { repo.name.present? }
    assert_redirected_to repositories_url
  end
end
