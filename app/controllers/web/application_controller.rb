# frozen_string_literal: true

class Web::ApplicationController < ApplicationController
  include AuthConcern
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = I18n.t('not_authorized')
    redirect_back(fallback_location: root_path)
  end
end
