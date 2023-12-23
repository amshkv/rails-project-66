# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@mshkv.ru'
  layout 'mailer'
end
