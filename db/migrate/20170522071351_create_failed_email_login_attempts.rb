class CreateFailedEmailLoginAttempts < ActiveRecord::Migration
  def change
    create_table :failed_email_login_attempts do |t|
      t.string :email, index: true
      t.integer :failed_attempts, default: 0
      t.datetime :locked_at
      t.timestamps null: true
    end
    
  end
end
