class AuthenticatedController < ApplicationController
  before_action :authenticate_user!, :complete_setup!, :mfa_verify!
  before_action :redirect_if_free_user

private

  def redirect_if_free_user
    if current_user.free?
      redirect_to my_profile_path
    end
  end

  def complete_setup!
    unless current_user.setup_complete?
      redirect_to setup_account_path 
    end
  end

  def is_admin?
    unless current_user.admin?
      redirect_to root_path
    end
  end

  def mfa_verify!  
    if current_user.mfa_verify? && !session[:mfa] 
      redirect_to mfa_path
    end
  end
end
