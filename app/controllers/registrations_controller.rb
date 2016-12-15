class RegistrationsController < Devise::RegistrationsController

protected

  def after_inactive_sign_up_path_for(resource)
    thank_you_path
  end

  def sign_up_params
    params[:user][:user_profile_attributes][:date_of_birth] = date_format
    params.require(:user)
      .permit(:email, :password, :password_confirmation,
        user_profile_attributes: [
          :first_name, :middle_name, :last_name, :date_of_birth
        ])
  end

  def account_update_params
    params[:user][:user_profile_attributes][:date_of_birth] = date_format
    params.require(:user)
      .permit(:email, :password, :password_confirmation,
        user_profile_attributes: [
          :first_name, :middle_name, :last_name, :date_of_birth
        ])
  end
  
  private
  
  def date_format
    user_profile_params = params[:user][:user_profile_attributes]
    return user_profile_params[:date_of_birth] unless user_profile_params[:date_of_birth].include?('/')
    
    date_params = user_profile_params[:date_of_birth].split('/')
    year = date_params[2]
    month = date_params[0]
    day = date_params[1]
    "#{year}-#{month}-#{day}"
  end
end
