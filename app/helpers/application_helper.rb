# frozen_string_literal: true

module ApplicationHelper
  include AuthConcern

  def repository_name(repository)
    repository.full_name || '-'
  end
end
