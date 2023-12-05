# frozen_string_literal: true

module ApplicationHelper
  include AuthConcern

  # NOTE: или это в презентере должно быть?
  def repository_name(repository)
    repository.full_name || '-'
  end
end
