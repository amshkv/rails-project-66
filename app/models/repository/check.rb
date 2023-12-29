# frozen_string_literal: true

# == Schema Information
#
# Table name: repository_checks
#
#  id                  :integer          not null, primary key
#  aasm_state          :string
#  lint_messages       :json
#  lint_messages_count :integer
#  passed              :boolean          default(FALSE), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  commit_id           :string
#  repository_id       :integer          not null
#
# Indexes
#
#  index_repository_checks_on_repository_id  (repository_id)
#
# Foreign Keys
#
#  repository_id  (repository_id => repositories.id)
#
class Repository::Check < ApplicationRecord
  include AASM
  belongs_to :repository

  aasm do
    state :created, initial: true
    state :started
    state :finished
    state :failed

    event :mark_as_started do
      transitions from: :created, to: :started
    end

    event :mark_as_finish do
      transitions from: :started, to: :finished
    end

    event :mark_as_failed do
      transitions from: :started, to: :failed
    end
  end
end
