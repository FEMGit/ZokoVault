class UsageMetricsController < AuthenticatedController
  before_action :check_privileges
  before_action :stats, only: [:index]
  before_action :death_traps, only: [:errors]
  before_action :set_user_death_drap, only: [:error_details]

  helper_method :documents_per_user, :login_count_per_week,
                :login_count_per_week_avg, :session_length_avg,
                :site_completed, :categories_left_to_complete,
                :shares_per_user, :user_invitations_count, :user_invitations_emails,
                :user_traffic
  before_action :set_user, only: [:edit_user, :statistic_details]
  before_action :set_user_traffic, only: [:statistic_details]

  # Breadcrumbs navigation
  add_breadcrumb "Usage Metrics", :usage_metrics_path, only: [:statistic_details, :error_details, :edit_user]
  before_action :set_statistic_details_crumbs, only: [:statistic_details, :edit_user]
  before_action :set_edit_user_crumbs, only: [:edit_user]
  add_breadcrumb "Error Details", :user_error_details_path, only: [:error_details]

  include UserTrafficModule

  def page_name
    case action_name
      when 'index'
        return "ZokuVault Users"
      when 'error_details'
        return "Usage Metrics Error Page"
      when 'edit_user'
        user = User.find_by(id: params[:id])
        return "Admin Edit User - #{user.name}"
      when 'statistic_details'
        user = User.find_by(id: params[:id])
        return "Admin User Details - #{user.name}"
    end
  end

  def set_edit_user_crumbs
    return unless @user.present?
    add_breadcrumb @user.name.to_s + " - Edit User", admin_edit_user_path(@user)
  end

  def set_statistic_details_crumbs
    return unless @user.present?
    add_breadcrumb @user.name.to_s + " - User Details", statistic_details_path(@user)
  end

  def index; end

  def errors; end

  def error_details; end

  def edit_user
    @subscription_info = subscription_info
  end

  def statistic_details; end

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

  def set_user
    @user = User.find(params[:id])
  end

  def set_user_traffic
    @user_traffic = UserTraffic.for_user(@user)
  end

  def delete_system_models(models)
    return if models.blank?
    models.delete(UserDeathTrap)
    models.delete(UserActivity)
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

  def user_invitations_emails(user)
    invited_user_emails = ShareInvitationSent.for_user(user).select { |inv| inv.user_invite_status == "new_user" }.map(&:contact_email)
    emails = []
    invited_user_emails.each do |invited_user_email|
      emails << User.where("email ILIKE ?", invited_user_email).where(:sign_in_count => 0..Float::INFINITY).first.try(:email)
    end
    emails.compact
  end

  def user_invitations_count(user)
    user_invitations_emails(user).count
  end

  def shares_per_user(user)
    Share.for_user(user).map(&:contact_id).uniq.count
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
    models_with_user = all_models.select { |x| x.table_exists? && x.column_names.include?("user_id") }
    completed_count = models_with_user.collect { |x| x.where(:user_id => user.id).any? }.count(true)
    models_with_user_count = models_with_user.map(&:name).count
    ((completed_count.to_f / models_with_user_count) * 100).round(2)
  end

  def categories_left_to_complete(user)
    update_model_list
    all_models = ActiveRecord::Base.descendants
    delete_system_models(all_models)
    models_with_user = all_models.select { |x| x.table_exists? && x.column_names.include?("user_id") }
    completed = models_with_user.select { |x| x.where(:user_id => user.id).any? }
    (models_with_user - completed).map(&:name)
  end

  def update_model_list
    Rails.application.eager_load!
  end

  def death_traps
    @user_errors = UserDeathTrap.last(1000)
  end

  def subscription_info
    sub = @user && @user.current_user_subscription
    if sub.blank?
      { status: :none, label: 'Free User', text: '' }
    elsif sub.trial?
      label  = "#{sub.active? ? 'Active' : 'Expired'} Trial Period"
      expire = "Expire#{sub.active? ? 's' : 'd'} At: #{sub.end_at}"
      { status: :trial, label: label, text: expire, active: sub.active? }
    elsif sub.full?
      label  = "#{sub.active? ? 'Active' : 'Expired'} Full Subscription"
      expire = "Expire#{sub.active? ? 's' : 'd'} At: #{sub.end_at}"
      { status: :full, label: label, text: expire, active: sub.active? }
    else
      { status: :unknown, label: 'Invalid Subscription State',
                           text: 'must be corrected manually' }
    end
  end
end
