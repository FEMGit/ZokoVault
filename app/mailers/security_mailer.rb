class SecurityMailer < ApplicationMailer

  def duplicate_sign_up(existing_user)
    return if existing_user.blank? ||
              existing_user.email.blank? ||
              !existing_user.persisted?
    @user = existing_user
    subject = "Attempted signup at ZokuVault"
    mail(to: existing_user.email, subject: subject)
  end

end
