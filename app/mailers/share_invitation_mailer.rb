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
  
  def corporate_user(corporate_contact, corporate_admin)
    @contact = corporate_contact
    @user = User.find_by(email: corporate_contact.emailaddress)
    @token_raw, token_enc = Devise.token_generator.generate(User, :reset_password_token)
    @user.reset_password_token = token_enc
    @user.reset_password_sent_at = Time.now
    @user.confirmed_at = Time.now
    @user.save(validate: false)
    @corporate_admin = corporate_admin
    mail(to: @contact.emailaddress, subject: "#{corporate_admin.name} created an account for you on ZokuVault!")
  end
end
