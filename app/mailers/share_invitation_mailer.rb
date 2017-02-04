class ShareInvitationMailer < ApplicationMailer
  default from: "no-reply@zokuvault.com"

  def new_user(contact, resource_owner)
    @contact = contact
    @resource_owner = resource_owner
    @sign_up_url = "http://zokuvault.com/sign_up" # XXX: change me to url helper!
    mail(to: @contact.emailaddress, subject: "#{resource_owner.name} sent you a share invitation on ZokuVault")
  end

  def existing_user(user, resource_owner)
    @user = user
    @resource_owner = resource_owner
    mail(to: @user.email, subject: "#{resource_owner.name} shared a document on ZokuVault")
  end
end
