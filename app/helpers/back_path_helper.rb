module BackPathHelper
  def back_path
    previous_url = request.referrer
    return nil unless previous_url.present?

    recognized_path = Rails.application.routes.recognize_path(previous_url)
    return nil if recognized_path[:action] == "catch_404"
    previous_url
  end
end