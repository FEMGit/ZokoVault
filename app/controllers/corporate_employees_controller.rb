class CorporateEmployeesController < CorporateBaseController
  before_action :set_corporate_contacts, :set_employee_account_user_emails, only: [:new, :edit]
  before_action :set_employee_accounts, only: [:show]
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
    super(account_type: CorporateAdminAccountUser.employee_type)
  end
  
  def show; end
  
  def new
    @user_account = User.new(user_profile: UserProfile.new)
    @user_account.confirm_email!
  end
  
  def edit; end
  
  def create
    @user_account = User.new(employee_account_params)
    @user_account.skip_password_validation!
    @user_account.skip_confirmation_notification!
    @user_account.confirm_email!
    
    if !employee_relationship_valid?(@user_account)
      respond_to_format_error(:new)
    else
      super(account_type: CorporateAdminAccountUser.employee_type, success_return_path: corporate_employees_path)
      add_employee_relationship(@user_account)
      save_employee_account_users
    end
  end
  
  def update
    if !employee_relationship_valid?(@user_account)
      respond_to_format_error(:edit)
    else
      super(account_type: CorporateAdminAccountUser.employee_type, success_return_path: corporate_employee_path(@corporate_profile) || corporate_employees_path,
            params_to_update: employee_account_params.except(:email))
      add_employee_relationship(@user_account)
      save_employee_account_users
    end
  end
  
  def save_employee_account_users
    new_user_ids = 
      if employee_account_user_params.present?
        employee_user_account_ids(contact_emails: employee_account_user_params[:user_accounts].values)
      else
        []
      end
    previous_user_id = @user_account.employee_users.map(&:id)
    ids_to_delete = previous_user_id - new_user_ids
    params_to_save = (new_user_ids - previous_user_id).collect { |x| [:user_account_id => x, :corporate_employee_id => @user_account.id] }.flatten
    CorporateEmployeeAccountUser.where(corporate_employee: @user_account, user_account_id: ids_to_delete).delete_all
    CorporateEmployeeAccountUser.create!(params_to_save)
    
    remove_employee_shares(ids_to_delete, @user_account)
    add_employee_shares(new_user_ids - previous_user_id, @user_account)
  end
  
  def remove_employee
    corporate_contact = corporate_contact_by_contact_id(params[:contact_id])
    corporate_profile = corporate_contact.try(:user_profile)
    return unless corporate_profile.present?
    respond_to do |format|
      corporate_clients = current_user.corporate_users.compact.reject { |x| x.corporate_employee? }
      if remove_employee_shares(corporate_clients.map(&:id), corporate_profile.user) &&
          CorporateAdminAccountUser.where(corporate_admin: current_user, user_account: corporate_profile.user).delete_all
        MailchimpService.new.add_to_subscription_based_list(corporate_profile.user)
        format.html { redirect_to corporate_employees_path, flash: { success: 'Employee was successfully destroyed.' } }
      else
        format.html { redirect_to corporate_employees_path, flash: { error: 'Error removing an employee, please try again later.' } }
      end
    end
  end
  
  def accounts_managed(contact)
    user = User.find_by(email: contact.emailaddress)
    return 0 unless user.present?
    user.employee_users.count
  end
  
  private
  
  def employee_relationship_valid?(corporate_employee)
    find_or_initialize_employee_profile(corporate_employee).valid?
  end
  
  def add_employee_relationship(corporate_employee)
    find_or_initialize_employee_profile(corporate_employee).save
  end
  
  def find_or_initialize_employee_profile(corporate_employee)
    employee_profile = CorporateEmployeeProfile.find_or_initialize_by(:corporate_employee => corporate_employee)
    employee_profile.relationship = employee_relationship_params[:employee_relationship]
    employee_profile.contact_type = 'Advisor'
    employee_profile
  end
  
  def respond_to_format_error(action)
    respond_to do |format|
      error_path(action)
      format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout], locals: @path[:locals] }
      format.json { render json: @user_accounts.errors, status: :unprocessable_entity }
    end
  end
  
  def add_employee_shares(user_ids, corporate_employee)
    user_ids.each do |user_id|
      next unless (user = User.find_by(:id => user_id)).present?
      corporate_emplooyee_contact = create_corporate_employee_contact_for_user_account(corporate_employee: corporate_employee, user_account: user)
      CorporateAdminService.add_category_share_for_corporate_employee(corporate_employee_contact: corporate_emplooyee_contact, corporate_admin: corporate_owner, user: user)
    end
  end
  
  def remove_employee_shares(user_ids, corporate_employee)
    user_ids.each do |user_id|
      next unless (user = User.find_by(:id => user_id)).present?
      corporate_emplooyee_contact = create_corporate_employee_contact_for_user_account(corporate_employee: corporate_employee, user_account: user)
      Share.where(contact_id: corporate_emplooyee_contact.id, user_id: user.id).destroy_all
    end
  end
  
  def set_employee_accounts
    return [] unless @corporate_contact.present?
    user = @corporate_contact.try(:user_profile).try(:user)
    @employee_accounts = user.present? ? user.employee_users : []
  end
  
  def set_employee_account_user_emails
    @employee_account_user_emails = @user_account.present? ? @user_account.employee_users.map(&:email).map(&:downcase) : []
  end
  
  def set_corporate_contacts
    return unless current_user.corporate_admin
    corporate_users_emails = CorporateAdminAccountUser.select { |x| x.corporate_admin == current_user && x.account_type == CorporateAdminAccountUser.client_type }
                                                      .map(&:user_account).map(&:email).map(&:downcase)
    @corporate_contacts = Contact.for_user(current_user)
                                 .select { |c| (corporate_users_emails.include? c.emailaddress.downcase) && c.user_profile.present? }
  end
  
  def employee_account_params
    params.require(:user).permit(:email, :email_confirmation,
                                 user_profile_attributes: [ :first_name, :last_name ])
  end
  
  def employee_relationship_params
    params.require(:user).permit(:employee_relationship)
  end
  
  def employee_account_user_params
    return nil unless params[:corporate_employee].present?
    params.require(:corporate_employee)
  end
  
  def employee_user_account_ids(contact_emails:)
    User.select { |u| contact_emails.map(&:downcase).include? u.email.downcase }.reject { |u| !u.corporate_user_by_admin?(current_user) }.map(&:id)
  end
  
  def user_accounts
    CorporateAdminAccountUser.select { |x| x.corporate_admin == current_user && x.account_type == CorporateAdminAccountUser.employee_type }.map(&:user_account)
  end
  
  def error_path(action)
    @path = ReturnPathService.error_path(current_user, current_user, params[:controller], action)
    corporate_employee_error_breadcrumb_update
    set_corporate_contacts
    set_employee_account_user_emails
  end

  def success_path(path)
    ReturnPathService.success_path(current_user, current_user, path, path)
  end
end
