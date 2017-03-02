class MessageMailer < ApplicationMailer
  layout 'mailer'
  
  def new_message(message)
    @message = message
    mail subject: "Message from #{message.name}"
  end
  
  def new_message_support(message, to)
    @message = message
    mail subject: "Email Support - #{message.name}", to: to
  end
end
