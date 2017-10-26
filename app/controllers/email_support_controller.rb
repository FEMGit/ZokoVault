class EmailSupportController < AuthenticatedController
  include BackPathHelper
  include SanitizeModule
  attr_reader :referrer
  
  skip_before_filter :mfa_verify!, :redirect_if_free_user
  
  layout :pick_layout
  
  def page_name
    case action_name
      when 'index'
        return "ZokuVault Support"
    end
  end

  def index
    @message = Message.new
  end

  def send_email
    user_name = [params[:first_name], params[:last_name]].join ' '

    @message = Message.new(
      name: user_name,
      email: params[:email],
      message_content: params[:message],
      phone_number: params[:two_factor_phone_number],
      preferred_contact_method:  params["user"]["connect_by"].capitalize)

    if @message.valid? && @message.message_content.length > 0
      MessageMailer.new_message_support(@message, admin_emails).deliver
      set_thank_you_close_path
      render :thank_you
    else
      @message.errors.add(:message_content, :not_implemented, message: "required") if @message.message_content.length == 0
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
  
  def pick_layout
    missing_mfa? ? 'without_sidebar_layout' : 'application'
  end
  
  def set_thank_you_close_path
    if missing_mfa?
      @close_path = destroy_user_session_path
      @close_method = :delete
    else
      @close_path = root_path
      @close_method = :get
    end
  end
end
