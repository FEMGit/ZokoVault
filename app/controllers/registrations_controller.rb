class RegistrationsController < Devise::RegistrationsController

  def create
    super do |resource|
      if valid_except_email_taken?(resource)
        set_flash_message! :notice, :signed_up_but_unconfirmed
        expire_data_after_sign_in!
        alert_existing_user_by_email(resource)
        redirect_to thank_you_path
        return
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

end
