class CorporateAccountsController < AuthenticatedController
  before_action :redirect_unless_corporate_admin
  
  before_action :set_index_breadcrumbs, :only => %w(new edit show)
  before_action :set_new_crumbs, only: [:new]
  include BreadcrumbsErrorModule
  include UserTrafficModule
  
  def set_index_breadcrumbs
    add_breadcrumb "Corporate Account", corporate_accounts_path
  end

  def set_new_crumbs
    add_breadcrumb "Add Account", new_corporate_account_path
  end
  
  def page_name
    case action_name
      when 'index'
        return "Corporate Account - Main Page"
      when 'new'
        return "Corporate Account - Add Account"
    end
  end
  
  def index
    @corporate_users = CorporateAdminAccountUser.select { |x| x.corporate_admin == current_user }.map(&:user_account)
  end
  
  def new
    @user_account = User.new(user_profile: UserProfile.new)
  end
  
  def create
    @user_account = User.new(user_account_params)
    @user_account.skip_password_validation!
    @user_account.skip_confirmation_notification!
    respond_to do |format|
      if @user_account.save
        CorporateAdminAccountUser.create(corporate_admin: current_user, user_account: @user_account)
        format.html { redirect_to success_path, flash: { success: 'User Account successfully created.' } }
        format.json { render :show, status: :created, location: @user_account }
      else
        error_path(:new)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout], locals: @path[:locals] }
        format.json { render json: @user_accounts.errors, status: :unprocessable_entity }
      end
    end
  end
  
  private
  
  def user_account_params
    params.require(:user).permit(:email,
                                 user_profile_attributes: [ :first_name, :last_name,
                                                            :two_factor_phone_number,
                                                            :phone_number, :street_address_1,
                                                            :city, :state, :zip ])
  end
  
  def error_path(action)
    @path = ReturnPathService.error_path(current_user, current_user, params[:controller], action)
    corporate_account_error_breadcrumb_update
  end

  def success_path
    ReturnPathService.success_path(current_user, current_user, corporate_accounts_path, corporate_accounts_path)
  end
  
  def redirect_unless_corporate_admin
    redirect_to root_path unless current_user.present? && current_user.corporate_admin
  end
end
