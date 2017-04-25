class AuthenticatedController < ApplicationController
  before_action :authenticate_user!, :complete_setup!, :mfa_verify!
  before_action :redirect_if_free_user

private

 def redirect_if_free_user
    if current_user && current_user.setup_complete? &&
       current_user.free? && !permitted_page_free_user? &&
       current_user.mfa_verify? && session[:mfa] 
      redirect_to shares_path
    end
  end

  def complete_setup!
    unless current_user.setup_complete?
      redirect_to terms_of_service_account_path 
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
  
  private
  
  def permitted_page_free_user?
    (controller_name && (UserPageAccess::FREE.include? controller_name)) ||
      params[:shared_user_id].present?
  end
end
