module BackPathHelper
  def back_path(previous_path = nil)
    previous_url = previous_path || request.referrer
    return nil unless previous_url.present?

    return root_path if (previous_url.eql? root_url) || (previous_url.eql? new_user_session_url)
    recognized_path = Rails.application.routes.recognize_path(previous_url)
    return nil if recognized_path[:action] == "catch_404"
    return root_path if previous_url.eql? request.original_url
    previous_url
  end
end