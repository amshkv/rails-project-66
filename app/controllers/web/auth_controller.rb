# frozen_string_literal: true

class Web::AuthController < Web::ApplicationController
  def callback
    auth = request.env['omniauth.auth']

    email = auth.info.email
    nickname = auth.info.nickname
    token = auth.credentials.token

    user = User.find_or_initialize_by(email:)
    user.nickname = nickname
    user.token = token

    if user.save!
      sign_in(user)
      redirect_to root_path, notice: I18n.t('login.success')
    else
      redirect_to root_path, alert: I18n.t('login.failure')
    end
  end

  def logout
    sign_out
    redirect_to root_path, notice: I18n.t('logout.success')
  end
end
