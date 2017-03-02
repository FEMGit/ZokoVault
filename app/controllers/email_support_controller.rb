class EmailSupportController < AuthenticatedController
  include BackPathHelper
  include SanitizeModule
  attr_reader :referrer
  
  def index
  end
  
  def thank_you
  end
  
  def send_email
    message = Message.new(name: current_user.name, email: current_user.email, message_content: params[:message],
                          phone_number: user_phone_numbers)
    if message.valid? && message.message_content.length > 0
      MessageMailer.new_message_support(message, admin_emails).deliver
      render :thank_you
    else
      render :index
    end
  end
  
  private
  
  def admin_emails
    EmailSupport::ADMIN_EMAILS.join(",")
  end
  
  def user_phone_numbers
    user_phones = ""
    user_phones += add_phone_number?(current_user.phone_number, user_phones) ? (current_user.phone_number + ' ') : ''
    user_phones += add_phone_number?(current_user.phone_number_mobile, user_phones) ? (current_user.phone_number_mobile + ' ') : ''
    user_phones += add_phone_number?(current_user.two_factor_phone_number, user_phones) ? (current_user.two_factor_phone_number + ' ') : ''
    return user_phones
  end
  
  def add_phone_number?(phone_number, user_phones)
    phone_number.present? && (user_phones.exclude? phone_number)
  end
end