class MessagesController < ApplicationController
  def create
    @message = Message.new(message_params)
    if @message.valid?
      MessageMailer.new_message(@message).deliver
      redirect_to contact_us_path, notice: "Your message has been sent."
    else
      render 'pages/contact-us'
    end
  end
  
  private
  
  def message_params
    params.require(:user_message).permit(:name, :phone_number, :email, :message_content)
  end
  
end
