# frozen_string_literal: true

class CreateRepositoryChecks < ActiveRecord::Migration[7.0]
  def change
    create_table :repository_checks do |t|
      t.string :commit_id
      t.string :aasm_state
      t.integer :lint_messages_count
      t.boolean :success_check, null: false, default: false
      t.json :lint_messages
      t.references :repository, null: false, foreign_key: true

      t.timestamps
    end
  end
end
