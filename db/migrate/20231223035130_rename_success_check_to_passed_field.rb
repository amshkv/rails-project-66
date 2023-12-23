# frozen_string_literal: true

class RenameSuccessCheckToPassedField < ActiveRecord::Migration[7.0]
  def change
    rename_column :repository_checks, :success_check, :passed
  end
end
