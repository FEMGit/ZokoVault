module BackPathHelper
  def save_return_to_path
    return unless current_user && !request.xhr? && request.get?
    CookiesService.save(current_user.id.to_s + "_return_to", request.fullpath)
  end
  
  def back_path(previous_path = nil)
    previous_url = previous_path || request.referrer
    return nil unless previous_url.present?

    return root_path if (previous_url.eql? root_url) || (previous_url.eql? new_user_session_url)
    recognized_path = Rails.application.routes.recognize_path(previous_url) rescue nil
    return if recognized_path.nil?

    return root_path if previous_url.eql? request.original_url
    previous_url
  end
  
  def return_to_path
    return root_path unless current_user
    previous_path = CookiesService.pop(current_user.id.to_s + "_return_to")
    recognized_path = Rails.application.routes.recognize_path(previous_path) rescue nil
    return root_path if recognized_path.nil?
    previous_path
  end
end
