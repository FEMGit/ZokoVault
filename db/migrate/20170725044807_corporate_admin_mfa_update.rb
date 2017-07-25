class CorporateAdminMfaUpdate < ActiveRecord::Migration
  def change
    corporate_user_ids = User.where(:corporate_admin => true).map(&:id)
    UserProfile.where(:user_id => corporate_user_ids).update_all(:mfa_frequency => UserProfile.mfa_frequencies[:always])
  end
end
