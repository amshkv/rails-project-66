# frozen_string_literal: true

class AddGithubIdForRepository < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :github_id, :string
    add_index :repositories, :github_id, unique: true
  end
end
