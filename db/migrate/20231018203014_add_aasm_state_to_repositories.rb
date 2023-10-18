# frozen_string_literal: true

class AddAasmStateToRepositories < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :aasm_state, :string
  end
end
