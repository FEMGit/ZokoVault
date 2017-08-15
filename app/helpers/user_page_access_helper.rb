module UserPageAccessHelper
  def white_listed(type:)
    case type
      when :trial
        [ trial_ended_path,
          trial_membership_update_path,
          trial_questionnaire_path,
          payment_path,
          update_payment_account_settings_path,
          subscriptions_account_path,
          apply_promo_code_account_path,
          account_path,
          mfa_path,
          mfa_verify_code_account_path ]
      when :corporate_admin, :corporate_employee
      [ shared_expired_corporate_path(:id) ]
    end
  end
  
  def black_listed(type:)
    case type
      when :corporate_employee
        [ corporate_account_settings_path,
          edit_corporate_settings_path,
          update_corporate_settings_path(:id),
          corporate_billing_information_path]
    end
  end
  
  def contains_paths?(paths, request_path)
    requested_get_path = Rails.application.routes.recognize_path(request_path) rescue nil
    requested_post_path = Rails.application.routes.recognize_path(request_path, method: :post) rescue nil
    
    paths.each do |p|
      get_path = Rails.application.routes.recognize_path(p) rescue nil
      post_path = Rails.application.routes.recognize_path(p, method: :post) rescue nil
      
      if paths_equal?(get_path, requested_get_path) || paths_equal?(post_path, requested_post_path)
        return true
      end
    end
    false
  end
  
  private
  
  def paths_equal?(path1, path2)
    return false unless path1.present? && path2.present?
    path1[:controller] == path2[:controller] && path1[:action] == path2[:action]
  end
end
