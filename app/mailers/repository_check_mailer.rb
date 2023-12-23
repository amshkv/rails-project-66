# frozen_string_literal: true

class RepositoryCheckMailer < ApplicationMailer
  def failed_check
    @check = params[:check]

    mail to: @check.repository.user.email
  end
end
