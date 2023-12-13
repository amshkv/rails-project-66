# frozen_string_literal: true

class Repository::CheckPolicy < ApplicationPolicy
  def create?
    repository_author?
  end

  def show?
    repository_author?
  end

  private

  def repository_author?
    record.repository.user == user
  end
end
