class CreatePerUserEncryptionKeys < ActiveRecord::Migration
  def change
    create_table :per_user_encryption_keys do |t|
      t.references :user, index: true, foreign_key: true
      t.binary :ciphertext, null: false
      t.string :aws_key_id, null: false
    end
  end
end
