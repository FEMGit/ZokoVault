class AccountsController < ApplicationController
  def setup

  end

  def update
    current_user.update_attributes user_params
    redirect_to account_path
  end

  def show
  end

private
  
  def user_params
    params.require(:user).permit(
      user_profile_attributes: [
        :signed_terms_of_service,
        :phone_number_raw,
        :phone_code,
        :mfa_frequency,
        security_questions_attributes: []
      ])

    params.require(:user).permit! # TODO: fix the security questions array problem

  end
end
