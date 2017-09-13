class VaultInheritanceInvitationMailer < ApplicationMailer
  layout 'mailer'
  
  def new_user(contact, resource_owner)
    @contact = contact
    @resource_owner = resource_owner
    mail(to: @contact.emailaddress, subject: "#{resource_owner.name} designates you as the contingent owner for ZokuVault!", :cc => resource_owner.email)
  end

  def existing_user(user, resource_owner)
    @user = user
    @resource_owner = resource_owner
    mail(to: @user.email, subject: "#{resource_owner.name} designates you as the contingent owner for ZokuVault!", :cc => resource_owner.email)
  end
end