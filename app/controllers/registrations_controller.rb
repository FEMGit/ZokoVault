class RegistrationsController < Devise::RegistrationsController

protected

  def after_inactive_sign_up_path_for(resource)
    thank_you_path
  end

  def sign_up_params
    params.require(:user)
      .permit(:email, :password, :password_confirmation,
        user_profile_attributes: [
          :first_name, :middle_name, :last_name, :date_of_birth
        ])
  end

  def account_update_params
    params.require(:user)
      .permit(:email, :password, :password_confirmation,
        user_profile_attributes: [
          :first_name, :middle_name, :last_name, :date_of_birth
        ])
  end
end
