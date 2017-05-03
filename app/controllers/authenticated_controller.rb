class AuthenticatedController < ApplicationController
  before_action :authenticate_user!, :complete_setup!, :mfa_verify!
  before_action :redirect_if_free_user, :trial_check

private
  
  def trial_check
    if current_user && current_user.current_user_subscription &&
       current_user.current_user_subscription.expired_trial? && !trial_whitelist_page?
      redirect_to trial_ended_path
    end
  end

  def redirect_if_free_user
    if current_user && current_user.setup_complete? &&
       current_user.free? && !permitted_page_free_user? &&
       ((current_user.mfa_verify? && session[:mfa]) || !current_user.mfa_verify?)
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
  
  def trial_whitelist_page?
    [trial_ended_path,
     trial_membership_update_path,
     trial_questionnaire_path,
     payment_path,
     subscriptions_account_path,
     apply_promo_code_account_path,
     account_path].include? request.path_info
  end
  
  def permitted_page_free_user?
    (controller_name && (UserPageAccess::FREE.include? controller_name)) ||
      params[:shared_user_id].present?
  end
end
