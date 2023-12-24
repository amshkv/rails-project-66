# frozen_string_literal: true

class AddUrlToRepository < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :url, :string
  end
end
