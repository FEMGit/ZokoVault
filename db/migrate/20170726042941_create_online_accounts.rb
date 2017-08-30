class CreateOnlineAccounts < ActiveRecord::Migration
  def change
    create_table :online_accounts do |t|
      t.references :user, index: true, foreign_key: true
      t.string :website
      t.string :username
      t.binary :password
      t.string :notes
      t.timestamps null: false
    end
  end
end
