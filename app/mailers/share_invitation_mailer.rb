class ShareInvitationMailer < ApplicationMailer
  layout 'mailer'

  def new_user(contact, resource_owner)
    @contact = contact
    @resource_owner = resource_owner
    mail(to: @contact.emailaddress, subject: "#{resource_owner.name} sent you an invitation for ZokuVault!", :cc => resource_owner.email)
  end

  def existing_user(user, resource_owner)
    @user = user
    @resource_owner = resource_owner
    mail(to: @user.email, subject: "#{resource_owner.name} shared with you on ZokuVault!", :cc => resource_owner.email)
  end
  
  def corporate_user(corporate_contact, corporate_manager, account_type = "client")
    @contact = corporate_contact
    @user = User.find_by(email: corporate_contact.emailaddress)
    @token_raw, token_enc = Devise.token_generator.generate(User, :reset_password_token)
    @user.reset_password_token = token_enc
    @user.reset_password_sent_at = Time.now
    @user.confirmed_at = Time.now
    @user.save(validate: false)
    corporate_admin = corporate_manager.corporate_employee? ? corporate_manager.corporate_admin_by_user : corporate_manager
    @corporate_manager = corporate_manager
    @corporate_profile = corporate_admin.corporate_account_profile
    @account_type = account_type
    mail(to: @contact.emailaddress, subject: "#{corporate_manager.name} created an account for you on ZokuVault!")
  end
end
