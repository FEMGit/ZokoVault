class ShareInvitationMailer < ApplicationMailer
  default from: '"ZokuVault" <support@zokuvault.com>'

  def new_user(contact, resource_owner)
    @contact = contact
    @resource_owner = resource_owner
    mail(to: @contact.emailaddress, subject: "#{resource_owner.name} sent you a share invitation on ZokuVault", :cc => resource_owner.email)
  end

  def existing_user(user, resource_owner)
    @user = user
    @resource_owner = resource_owner
    mail(to: @user.email, subject: "#{resource_owner.name} shared a document on ZokuVault", :cc => resource_owner.email)
  end
end
