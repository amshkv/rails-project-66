# frozen_string_literal: true

# NOTE: без en локали падает ошибка i18n для faker
# https://github.com/faker-ruby/faker/issues/278
I18n.available_locales = %i[en ru]
I18n.default_locale = :ru
