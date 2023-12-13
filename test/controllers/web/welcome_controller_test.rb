# frozen_string_literal: true

require 'test_helper'

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  test 'get root page' do
    get root_path
    assert_response :success
  end
end
