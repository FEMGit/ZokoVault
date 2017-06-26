class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include Pundit
  protect_from_forgery with: :exception
  after_filter :user_activity
  rescue_from Exception, :with => :death_trap_handle
  rescue_from ActionController::RoutingError, :with => :death_trap_handle
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  around_filter :save_current_user
  before_action :redirect_if_user_terms_of_service_empty
  
  rescue_from ActionController::InvalidAuthenticityToken do
    flash[:alert] = "Your session expired. Please sign in again to continue."
    redirect_to new_user_session_path
  end

  private
  
  def redirect_if_user_terms_of_service_empty
    return if (user_signed_in? && current_user.signed_terms_of_service?) ||
               !user_signed_in?
    
    current_path = 
      if (request.fullpath.eql? root_path)
        root_path
      else
        Rails.application.routes.recognize_path(request.fullpath)
      end
    terms_of_service_path = Rails.application.routes.recognize_path(terms_of_service_account_path)
    if current_path != terms_of_service_path
      redirect_to terms_of_service_account_path
    end
  end
  
  def save_current_user
    Thread.current[:current_user] = current_user
    begin yield
      ensure
      Thread.current[:current_user] = nil
    end
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(root_url)
  end

  def user_activity
    current_user.try :touch
  end
  
  def death_trap_handle(exception)
    error = exception.message
    user_death_trap = UserDeathTrap.new(user: current_user, page_terminated_on: sign_up_path, error_message: error)
    user_death_trap.save
    raise exception
  end

  # Run Schedule for handling online users
  scheduler = Rufus::Scheduler.new
  scheduler.every Rails.application.config.x.UserOnlineRangeScheduleFormat do
    online_users = User.online
    user_ids = online_users.collect(&:id)
    UserActivity.for_date(Date.current).where(user_id: user_ids).update_all("session_length = session_length + 5")
  end
  
  scheduler.every Rails.application.config.x.UsageMetricsUpdateScheduleFormat do
    UserService.update_user_information
  end
end