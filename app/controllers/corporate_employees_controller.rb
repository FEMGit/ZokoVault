class CorporateEmployeesController < CorporateBaseController
  helper_method :accounts_managed
  
  def set_index_breadcrumbs
    add_breadcrumb "Employee Accounts", corporate_employees_path
  end

  def set_new_crumbs
    add_breadcrumb "Add Employee Account", new_corporate_employee_path
  end
  
  def set_details_crumbs
    add_breadcrumb "#{@corporate_contact.try(:name)} Details", corporate_employee_path(@corporate_contact.user_profile_id)
  end
  
  def set_edit_crumbs
    add_breadcrumb "Edit Employee Account", edit_corporate_employee_path(@corporate_contact.user_profile_id)
  end
  
  def page_name
    case action_name
      when 'index'
        return "Employee Accounts - Main Page"
      when 'new'
        return "Employee Accounts - Add Account"
      when 'edit'
        return "Employee Accounts - Edit Account"
      when 'show'
        return "Employee Accounts - Details"
    end
  end
  
  def index
    super(account_type: "Employee")
  end
  
  def show; end
  
  def new
    @user_account = User.new(user_profile: UserProfile.new)
    @user_account.confirm_email!
  end
  
  def create
    @user_account = User.new(employee_account_params)
    @user_account.skip_password_validation!
    @user_account.skip_confirmation_notification!
    @user_account.confirm_email!
    super(account_type: "Employee", success_return_path: corporate_employees_path)
  end

  def update
    super(account_type: "Employee", success_return_path: corporate_employee_path(@corporate_profile) || corporate_employees_path,
          params_to_update: employee_account_params.except(:email))
  end
  
  def accounts_managed(user)
    0
  end
  
  private
  
  def employee_account_params
    params.require(:user).permit(:email, :email_confirmation,
                                 user_profile_attributes: [ :first_name, :last_name,
                                                            :two_factor_phone_number ])
  end
  
  def user_accounts
    CorporateAdminAccountUser.select { |x| x.corporate_admin == current_user && x.account_type == "Employee" }.map(&:user_account)
  end
  
  def error_path(action)
    @path = ReturnPathService.error_path(current_user, current_user, params[:controller], action)
    corporate_employee_error_breadcrumb_update
  end

  def success_path(path)
    ReturnPathService.success_path(current_user, current_user, path, path)
  end
end
