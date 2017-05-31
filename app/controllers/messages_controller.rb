class MessagesController < ApplicationController
  layout 'without_sidebar_layout'
  
  def create
    @message = Message.new(message_params)
    respond_to do |format|
      if @message.valid?
        MessageMailer.new_message(@message).deliver
        format.html { redirect_to contact_us_path, flash: { success: "Your message has been sent." } }
        format.json { render :show, status: :created, location: @message }
      else
        format.html { render 'pages/contact_us' }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end
  
  private
  
  def message_params
    params.require(:user_message).permit(:name, :phone_number, :email, :message_content)
  end
end
