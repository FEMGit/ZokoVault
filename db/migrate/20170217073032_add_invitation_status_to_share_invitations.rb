class AddInvitationStatusToShareInvitations < ActiveRecord::Migration
  def change
    add_column :share_invitation_sents, :user_invite_status, :string
  end
end
