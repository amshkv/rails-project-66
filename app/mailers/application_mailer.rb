# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('BASE_MAIL', 'no-reply@localhost')
  layout 'mailer'
end
