class UpdateCorporateAdminContactAvatars < ActiveRecord::Migration
  def change
    corporate_admin_ids = CorporateAdminAccountUser.all.map(&:corporate_admin_id).uniq
    User.find(corporate_admin_ids).each do |corporate_admin|
      account_profile = CorporateAccountProfile.find_by(user: corporate_admin)
      corporate_admin_avatar = corporate_admin.user_profile.photourl
      
      corporate_admin.corporate_users.each do |corporate_user|
        corporate_contact = Contact.for_user(corporate_user).where(emailaddress: corporate_admin.email).first
        next unless corporate_contact
        corporate_contact.update(photourl: corporate_admin_avatar)
      end
    end
  end
end
