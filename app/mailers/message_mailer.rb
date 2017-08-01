class MessageMailer < ApplicationMailer
  layout 'mailer'

  def membership_ended(message)
    @message = message
    mail subject: "Membership ended #{message.name}"
  end

  def new_message(message)
    @message = message
    mail subject: "Message from #{message.name}"
  end

  def new_message_support(message, to)
    @message = message
    mail subject: "Email Support - #{message.name}", to: to
  end
  
  def corporate_account_information(corporate_profile, corporate_options_params)
    @corporate_profile = corporate_profile
    @provided_choice = corporate_options_params[:provide_to]
    @services = corporate_options_params[:services]
    @user = corporate_profile.user
    mail subject: "Corporate Account Options - #{@corporate_profile.business_name}", to: EmailSupport::ADMIN_EMAILS
  end
end
