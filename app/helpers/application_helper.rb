# frozen_string_literal: true

module ApplicationHelper
  include AuthConcern

  # NOTE: или это в презентере должно быть?
  def repository_name(repository)
    repository.full_name || '-'
  end

  def commit_name(commit_id)
    commit_id[0..6]
  end

  def commit_link(url, commit_id)
    link_to commit_name(commit_id), "#{url}/commit/#{commit_id}"
  end

  def file_path_link(check, path)
    id = check.id
    url = check.repository.url
    commit_id = check.commit_id
    relative_path = path.split(id.to_s).last[1..]
    link_to relative_path, "#{url}/blob/#{commit_id}/#{relative_path}"
  end
end
