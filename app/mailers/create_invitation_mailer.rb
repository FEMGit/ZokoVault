class CreateInvitationMailer < ApplicationMailer
  layout 'mailer'

  def corporate_user(corporate_contact, corporate_manager, account_type = "client")
    @contact = corporate_contact
    @user = User.find_by(email: corporate_contact.emailaddress)
    set_user_reset_password_information(@user)
    corporate_admin = corporate_manager.corporate_employee? ? corporate_manager.corporate_admin_by_user : corporate_manager
    @corporate_manager = corporate_manager
    @corporate_profile = corporate_admin.corporate_account_profile
    @account_type = account_type
    mail(to: @contact.emailaddress, subject: "#{corporate_manager.name} created an account for you on ZokuVault!")
  end
  
  def super_admin_user(super_admin_user, user_invited)
    @super_admin_user = super_admin_user
    @user_invited = user_invited
    set_user_reset_password_information(@user_invited)
    mail(to: user_invited.email, subject: "#{super_admin_user.name} created a ZokuVault account for you!")
  end
  
  def regular_user(user)
    @user = user
    set_user_reset_password_information(@user)
    mail(to: @user.email, subject: "Confirmation instructions")
  end
  
  private
  
  def set_user_reset_password_information(user)
    @token_raw, token_enc = Devise.token_generator.generate(User, :reset_password_token)
    user.reset_password_token = token_enc
    user.reset_password_sent_at = Time.now
    user.confirmation_sent_at = Time.now
    user.save(validate: false)
  end
end
