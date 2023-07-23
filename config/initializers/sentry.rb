# frozen_string_literal: true

Sentry.init do |config|
  # NOTE: такой хитрый обход чтобы сентри не запускалась на dev машине, а только на проде, где есть DSN переменная
  config.dsn = ENV.fetch('SENTRY_DSN', nil)
  config.breadcrumbs_logger = %i[active_support_logger http_logger]

  # To activate performance monitoring, set one of these options.
  # We recommend adjusting the value in production:
  config.traces_sample_rate = 1.0
  # or
  # config.traces_sampler = lambda do |_context|
  #   true
  # end
end
