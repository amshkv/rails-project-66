# frozen_string_literal: true

module AuthConcern
  extend ActiveSupport::Concern

  def sign_in(user)
    session[:user_id] = user.id
  end

  def sign_out
    reset_session
  end

  def signed_in?
    session[:user_id].present? && current_user.present?
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  # NOTE: на работе возник вопрос, надо ли этот метод делать со знаком восклицания? тут вроде никакой модификации не происходит
  def authenticate_user!
    redirect_to root_path, alert: I18n.t('not_authenticated') unless signed_in?
  end
end
