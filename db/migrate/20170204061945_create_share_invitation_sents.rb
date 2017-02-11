class CreateShareInvitationSents < ActiveRecord::Migration
  def change
    create_table :share_invitation_sents do |t|
      t.integer :user_id, index: true
      t.text :contact_email, index: true

      t.timestamps null: false
    end
  end
end
