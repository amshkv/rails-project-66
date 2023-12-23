# frozen_string_literal: true

require 'test_helper'

class Web::Repositories::ChecksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:base)
    @user_without_repositories = users(:without_repositories)
    @repository = repositories(:base)
    @repository_without_checks = repositories(:without_checks)
    @check = repository_checks(:finished)
  end

  test 'guest cant show check page' do
    get repository_check_path(@repository, @check)

    assert_redirected_to root_path
  end

  test 'not author cant show check page' do
    sign_in(@user_without_repositories)

    get repository_check_path(@repository, @check)

    assert_redirected_to root_path
  end

  test 'signed user get finished check show' do
    sign_in(@user)

    get repository_check_path(@repository, @check)

    assert_response :success
  end

  test 'signed user get redirect on started check' do
    sign_in(@user)
    check = repository_checks(:started)

    get repository_check_path(@repository, check)

    assert_redirected_to repository_path(@repository)
  end

  test 'guest cant create check' do
    post repository_checks_path(@repository)
    assert_redirected_to root_path
  end

  test 'another signed user cant create check' do
    sign_in(@user_without_repositories)

    post repository_checks_path(@repository_without_checks)

    checks = Repository::Check.where repository: @repository_without_checks.id

    assert_redirected_to root_path
    assert { checks.empty? }
  end

  test 'signed user create check' do
    sign_in(@user)

    post repository_checks_path(@repository)

    check = Repository::Check.find_by repository: @repository.id
    assert_redirected_to repository_path(@repository)
    assert { check }
    assert { check.finished? }
    assert { check.passed == false }
    assert { check.lint_messages_count == 4 }
  end
end
