class UsageMetricsController < AuthenticatedController
  before_action :check_privileges
  before_action :stats, :death_traps, only: [:index]
  before_action :set_user_death_drap, only: [:details]
  helper_method :documents_per_user, :login_count_per_week,
                :login_count_per_week_avg, :session_length_avg,
                :site_completed, :categories_left_to_complete
  
  def index; end
  
  def details; end
  
  def statistic_details
    @user = User.find(params[:id])
  end
  
  def stats
    update_model_list
    uniq_user_count
    uniq_document_count
    users
  end
  
  def check_privileges
    if user_exists_and_admin?
      true
    else
      redirect_to root_path
    end
  end

  def user_exists_and_admin?
    current_user && current_user.admin?
  end
  
  private
  
  def delete_system_models(models)
    models.delete(UserDeathTrap)
    models.delete(UserActivity)
    models.delete(Folder)
    models.delete(Category)
    models.delete(Upload)
  end
  
  def set_user_death_drap
    @user_death_trap = UserDeathTrap.find_by_id(params[:id])
  end
  
  def uniq_user_count
    @uniq_user_count = User.all.uniq.count
  end
  
  def uniq_document_count
    @uniq_document_count = Document.all.uniq.count
  end
  
  def users
    @users = User.all.uniq
  end
  
  # Helper Methods
  def documents_per_user(user)
    Document.for_user(user).count
  end
  
  def login_count_per_week(user)
    current_day = Date.today
    start_week_date = current_day.at_beginning_of_week
    end_week_date = current_day.at_end_of_week
    UserActivity.for_user(user).date_range(start_week_date, end_week_date).sum(:login_count)
  end
  
  def login_count_per_week_avg(user)
    current_day = Date.today
    u_activity = UserActivity.for_user(user)
    return 0 unless u_activity.any?
    
    login_count = u_activity.sum(:login_count)
    first_date = u_activity.order("login_date DESC").last.login_date
    weeks = (current_day - first_date).to_i / 7
    return login_count if weeks.zero?
    (login_count.to_f / weeks).round(2)
  end
  
  def session_length_avg(user)
    u_activity = UserActivity.for_user(user)
    day_count = u_activity.count(:id)
    return 0 if day_count.zero?
    (u_activity.sum(:session_length).to_f / day_count).round(2)
  end
  
  def site_completed(user)
    all_models = ActiveRecord::Base.descendants
    delete_system_models(all_models)
    models_with_user = all_models.select { |x| x.column_names.include?("user_id") }
    completed_count = models_with_user.collect { |x| x.where(:user_id => user.id).any? }.count(true)
    models_with_user_count = models_with_user.map(&:name).count
    ((completed_count.to_f / models_with_user_count) * 100).round(2)
  end
  
  def categories_left_to_complete(user)
    update_model_list
    all_models = ActiveRecord::Base.descendants
    delete_system_models(all_models)
    models_with_user = all_models.select { |x| x.column_names.include?("user_id") }
    completed = models_with_user.select { |x| x.where(:user_id => user.id).any? }
    (models_with_user - completed).map(&:name)
  end
  
  def update_model_list
    Rails.application.eager_load!
  end
  
  def death_traps
    @user_errors = UserDeathTrap.all
  end
end
