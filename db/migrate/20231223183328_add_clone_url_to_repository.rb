# frozen_string_literal: true

class AddCloneUrlToRepository < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :clone_url, :string
  end
end
