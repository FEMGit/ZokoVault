class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include Pundit
  protect_from_forgery with: :exception
  after_filter :user_activity
  rescue_from Exception, :with => :death_trap_handle
  rescue_from ActionController::RoutingError, :with => :death_trap_handle
  
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(root_url)
  end

  def user_activity
    current_user.try :touch
  end
  
  def death_trap_handle(exception)
    requested_page = request.original_url
    error = exception.message
    user_death_trap = UserDeathTrap.new(user: current_user, page_terminated_on: requested_page, error_message: error)
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
end