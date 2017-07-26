class AuthenticatedController < ApplicationController
  include BackPathHelper
  before_action :authenticate_user!, :complete_setup!, :mfa_verify!
  before_action :redirect_if_free_user, :trial_check
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
      redirect_to mfa_path
    end
  end

  def is_free_user?
    current_user && current_user.setup_complete? && current_user.free?
  end

  def is_trial_user?
    current_user && current_user.current_user_subscription &&
                    current_user.current_user_subscription.trial?
  end

  def is_expired_trial_user?
    is_trial_user? && current_user.current_user_subscription.expired_trial?
  end

  def trial_whitelist_page?
    [ trial_ended_path,
      trial_membership_update_path,
      trial_questionnaire_path,
      payment_path,
      subscriptions_account_path,
      apply_promo_code_account_path,
      account_path,
      mfa_path,
      mfa_verify_code_account_path
    ].include?(request.path_info)
  end

  def permitted_page_free_user?
    controller_name && UserPageAccess::FREE.include?(controller_name)
  end

  def permitted_page_trial_expired_user?
    controller_name && UserPageAccess::TRIAL_EXPIRED.include?(controller_name)
  end

  def missing_mfa?
    if current_user.mfa_verify?
      !session[:mfa]
    else
      false
    end
  end

  def force_refresh_after_session_timeout
    response.headers['Refresh'] = (1.25 * Session::TIMEOUT_LIMIT).to_i.to_s
  end
end
