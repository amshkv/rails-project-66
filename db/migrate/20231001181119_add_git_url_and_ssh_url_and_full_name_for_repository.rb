# frozen_string_literal: true

class AddGitUrlAndSshUrlAndFullNameForRepository < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :git_url, :string
    add_column :repositories, :ssh_url, :string
    add_column :repositories, :full_name, :string
  end
end
