class RegistrationsController < Devise::RegistrationsController
  layout "no_header_footer_layout", only: [:new_email_only]
  after_action :allow_iframe, only: [:new_email_only]
  
  def new_email_only
    new
  end
  
  def create_email_only
    user = User.find_by(email: sign_up_params[:email])
    if user.present?
      expire_data_after_sign_in!
      alert_existing_user_by_email(user)
      redirect_to return_path_for_email_only_signup and return
    end
    
    user = User.new(email: sign_up_params[:email], uuid: SecureRandom.uuid)
    user.skip_password_validation!
    user.skip_confirmation_notification!
    user.skip_confirmation!
    unless user.save
      redirect_to return_path_for_email_only_signup(error: email_error_to_display(user))
    else
      InvitationService::CreateInvitationService.send_regular_user_invitation(user: user)
      redirect_to return_path_for_email_only_signup and return
    end
  end
  
  def create
    super do |resource|
      if valid_except_email_taken?(resource)
        set_flash_message! :notice, :signed_up_but_unconfirmed
        expire_data_after_sign_in!
        alert_existing_user_by_email(resource)
        redirect_to thank_you_path
        return
      elsif !resource.persisted?
        @email_error = email_error_to_display(resource)
      end
    end
  end

  protected

  def after_inactive_sign_up_path_for(resource)
    thank_you_path
  end

  def sign_up_params
    params.require(:user).permit :email, :password, :password_confirmation,
      user_profile_attributes: [:first_name, :last_name]
  end

  def account_update_params
    params[:user][:user_profile_attributes][:date_of_birth] = date_format
    params.require(:user)
      .permit(:email, :password, :password_confirmation,
        user_profile_attributes: [
          :first_name, :middle_name, :last_name, :date_of_birth
        ])
  end
  
  def return_path_for_email_only_signup(error: nil)
    if URI(request.referrer).path.eql? root_path
      flash[:error] = error
      error.present? ? root_path : thank_you_path
    else
      error.present? ? new_email_only_registrations_path(error: error) : email_registration_thank_you_path
    end
  end

  def date_format
    user_profile_attributes = params[:user][:user_profile_attributes]
    return user_profile_attributes[:date_of_birth] unless user_profile_attributes[:date_of_birth].include?('/')
    date_params = user_profile_attributes[:date_of_birth].split('/')
    year = date_params[2]
    month = date_params[0]
    day = date_params[1]
    "#{year}-#{month}-#{day}"
  end

  def valid_except_email_taken?(user)
    return false if user.persisted?
    return false if user.errors.size != 1
    user.errors.to_h == { email: "has already been taken" }
  end

  def alert_existing_user_by_email(attempted)
    existing = User.find_by(email: attempted.email)
    message  = SecurityMailer.duplicate_sign_up(existing)
    message.deliver if message
  end

  def email_error_to_display(user)
    all = user.errors.messages[:email]
    return if all.blank?
    all.find{ |msg| msg != "has already been taken" }
  end

end
