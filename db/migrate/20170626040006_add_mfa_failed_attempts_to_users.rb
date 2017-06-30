class AddMfaFailedAttemptsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mfa_failed_attempts, :integer, :default => 0, :null => false
  end
end
