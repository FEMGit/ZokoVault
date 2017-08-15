class AuthenticatedController < ApplicationController
  include BackPathHelper
  include UsersHelper
  include UserPageAccessHelper
  before_action :authenticate_user!, :complete_setup!, :mfa_verify!
  before_action :redirect_if_corporate_user, :redirect_if_free_user, :trial_check
  before_action :save_return_to_path
  before_action :force_refresh_after_session_timeout

  private

  def trial_check
    return unless is_expired_trial_user?
    if !trial_whitelist_page? && !permitted_page_trial_expired_user?
      redirect_to trial_ended_path
    end
  end

  def redirect_if_free_user
    return unless is_free_user?
    if !permitted_page_free_user? && params[:shared_user_id].blank?
      redirect_to shares_path
    end
  end
  
  def redirect_if_corporate_user
    return unless corporate?
    if corporate_admin?
      redirect_to corporate_accounts_path if !permitted_page_corporate_admin_user?
    elsif corporate_employee?
      redirect_to corporate_accounts_path if !permitted_page_corporate_employee_user?
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
    if missing_mfa?
      redirect_to mfa_path(shared_user_id: params[:shared_user_id])
    end
  end

  def is_free_user?
    current_user && current_user.setup_complete? && current_user.free? && !corporate?
  end

  def is_trial_user?
    current_user && current_user.current_user_subscription &&
                    current_user.current_user_subscription.trial?
  end

  def is_expired_trial_user?
    is_trial_user? && current_user.current_user_subscription.expired_trial?
  end

  def trial_whitelist_page?
    white_listed(type: :trial).include?(request.path_info)
  end

  def permitted_page_free_user?
    controller_name && UserPageAccess::CONTROLLERS[:free].include?(controller_name)
  end

  def permitted_page_trial_expired_user?
    controller_name && UserPageAccess::CONTROLLERS[:trial_expired].include?(controller_name)
  end

  def permitted_page_corporate_employee_user?
    shared_user_id = params[:shared_user_id]
    (((controller_name && shared_user_id.blank? && UserPageAccess::CONTROLLERS[:corporate_employee][:general_view].include?(controller_name)) ||
     (controller_name && shared_user_id.present? && UserPageAccess::CONTROLLERS[:corporate_employee][:shared_view].include?(controller_name))) &&
     !contains_paths?(black_listed(type: :corporate_employee), request.path_info)) ||
      contains_paths?(white_listed(type: :corporate_employee), request.path_info)
  end

  def permitted_page_corporate_admin_user?
    shared_user_id = params[:shared_user_id]
    (controller_name && shared_user_id.blank? && UserPageAccess::CONTROLLERS[:corporate][:general_view].include?(controller_name)) ||
      (controller_name && shared_user_id.present? && UserPageAccess::CONTROLLERS[:corporate][:shared_view].include?(controller_name)) ||
      contains_paths?(white_listed(type: :corporate_admin), request.path_info)
  end

  def missing_mfa?
    if params[:shared_user_id].present? && !current_user.mfa_verify?
      !session[:mfa_shared]
    elsif current_user.mfa_verify?
      !session[:mfa]
    else
      false
    end
  end

  def force_refresh_after_session_timeout
    response.headers['Refresh'] = (1.25 * Session::TIMEOUT_LIMIT).to_i.to_s
  end
end
