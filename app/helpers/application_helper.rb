# frozen_string_literal: true

module ApplicationHelper
  include AuthConcern

  # NOTE: или это в презентере должно быть?
  def repository_name(repository)
    repository.full_name || '-'
  end

  def commit_curl(repository_full_name, commit_id)
    "https://github.com/#{repository_full_name}/commit/#{commit_id}"
  end

  # def file_path_curl()
  # end
end
