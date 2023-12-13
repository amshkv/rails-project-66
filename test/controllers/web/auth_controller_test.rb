# frozen_string_literal: true

require 'test_helper'
class Web::AuthControllerTest < ActionDispatch::IntegrationTest
  test 'check github auth' do
    post auth_request_path(:github)
    assert_redirected_to callback_auth_path(:github)
  end

  test 'create' do
    auth_hash = {
      provider: 'github',
      uid: '12345',
      info: {
        email: Faker::Internet.email,
        nickname: Faker::Internet.username
      },
      credentials: {
        token: Faker::Internet.password
      }
    }

    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash::InfoHash.new(auth_hash)

    get callback_auth_path('github')
    assert_redirected_to root_path

    user = User.find_by(email: auth_hash[:info][:email].downcase)

    assert { user }
    assert { signed_in? }
  end

  test 'sign in existing user with another name' do
    user = users(:base)
    new_nickname = Faker::Name.first_name
    auth_hash = {
      provider: 'github',
      uid: '12345',
      info: {
        email: user.email,
        nickname: new_nickname
      },
      credentials: {
        token: user.token
      }
    }

    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash::InfoHash.new(auth_hash)

    get callback_auth_path('github')
    assert_redirected_to root_path

    user.reload

    assert { user.nickname == new_nickname }
    assert { signed_in? }
  end

  test 'logout' do
    user = users(:base)
    sign_in(user)

    delete auth_logout_path
    assert_redirected_to root_path

    assert { !signed_in? }
  end
end
