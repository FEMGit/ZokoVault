class CreateInvitationMailer < ApplicationMailer
  layout 'mailer'

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
  
  def super_admin_user(super_admin_user, user_invited)
    @super_admin_user = super_admin_user
    @user_invited = user_invited
    @token_raw, token_enc = Devise.token_generator.generate(User, :reset_password_token)
    @user_invited.reset_password_token = token_enc
    @user_invited.reset_password_sent_at = Time.now
    @user_invited.confirmation_sent_at = Time.now
    @user_invited.save(validate: false)
    mail(to: user_invited.email, subject: "#{super_admin_user.name} created a ZokuVault account for you!")
  end
end
