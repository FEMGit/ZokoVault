class ErrorsController < ApplicationController
  before_action :set_return_path, only: [:internal_server_error]
  
  def not_found_error
    @return_path = root_url
  end
  
  def internal_server_error
  end
  
  private
  
  def set_return_path
    previous_path = 
      if request.referer.blank?
        nil
      else
        Rails.application.routes.recognize_path(request.referer)
      end
    
    @return_path = 
      if previous_path.blank?
        root_url
      else 
        request.referer
      end
  end
end