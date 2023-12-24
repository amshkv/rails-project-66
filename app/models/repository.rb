# frozen_string_literal: true

# == Schema Information
#
# Table name: repositories
#
#  id         :integer          not null, primary key
#  aasm_state :string
#  clone_url  :string
#  full_name  :string
#  git_url    :string
#  language   :string
#  name       :string
#  ssh_url    :string
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  github_id  :string
#  user_id    :integer          not null
#
# Indexes
#
#  index_repositories_on_github_id  (github_id) UNIQUE
#  index_repositories_on_user_id    (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
class Repository < ApplicationRecord
  include AASM
  extend Enumerize

  belongs_to :user
  has_many :checks, dependent: :destroy

  enumerize :language, in: %i[javascript ruby], predicates: true

  validates :github_id, presence: true, uniqueness: true

  aasm do
    state :created, initial: true
    state :fetching
    state :fetched
    state :failed

    event :fetch do
      transitions from: %i[created fetched failed], to: :fetching
    end
    event :mark_as_fetched do
      transitions from: :fetching, to: :fetched
    end
    event :mark_as_failed do
      transitions to: :failed
    end
  end
end
