class AddKeyReferenceToOnlineAccounts < ActiveRecord::Migration
  def change
    add_reference :online_accounts, :per_user_encryption_key, index: true
    add_foreign_key :online_accounts, :per_user_encryption_keys
  end
end
