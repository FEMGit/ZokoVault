class CorporateAccountsController < CorporateBaseController
  before_action :set_account_settings_crumbs, only: [:account_settings, :edit_account_settings]
  before_action :set_edit_corporate_details_crumbs, only: [:edit_account_settings]
  
  def set_index_breadcrumbs
    add_breadcrumb "Corporate Account", corporate_accounts_path
  end

  def set_new_crumbs
    add_breadcrumb "Add Client User", new_corporate_account_path
  end
  
  def set_details_crumbs
    add_breadcrumb "#{@corporate_contact.try(:name)} Details", corporate_account_path(@corporate_contact.user_profile_id)
  end
  
  def set_edit_crumbs
    add_breadcrumb "Edit Client User", edit_corporate_account_path(@corporate_contact.user_profile_id)
  end
  
  def set_account_settings_crumbs
    add_breadcrumb "Corporate Account Settings", corporate_account_settings_path
  end
  
  def set_edit_corporate_details_crumbs
    add_breadcrumb "Edit Client User", edit_corporate_settings_path
  end
  
  def page_name
    case action_name
      when 'index'
        return "Corporate Account - Main Page"
      when 'new'
        return "Corporate Account - Add Account"
      when 'edit'
        return "Corporate Account - Edit Account"
      when 'show'
        return "Corporate Account - Details"
      when 'account_settings'
        return "Corporate Account - Account Settings"
      when 'edit_account_settings'
        return "Corporate Account - Edit Account Settings"
    end
  end
  
  def index
    super(account_type: CorporateAdminAccountUser.client_type)
  end
  
  def account_settings
    @corporate_profile = CorporateAccountProfile.find_by(user: current_user)
  end
  
  def show; end
  
  def new
    @user_account = User.new(user_profile: UserProfile.new)
    @user_account.confirm_email!
  end
  
  def edit_account_settings
    @corporate_profile = CorporateAccountProfile.find_or_initialize_by(user: current_user)
    @corporate_profile.save
  end
  
  def update_account_settings
    @corporate_profile = CorporateAccountProfile.find_by(id: params[:id])
    @corporate_profile.company_information_required!
    respond_to do |format|
      if @corporate_profile.update(corporate_settings_params)
        format.html { redirect_to success_path(corporate_account_settings_path), flash: { success: 'Corporate Settings successfully updated.' } }
        format.json { render :index, status: :created, location: @corporate_profile }
      else
        error_path(:edit_account_settings)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout], locals: @path[:locals] }
        format.json { render json: @corporate_profile.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def edit; end
  
  def create
    @user_account = User.new(user_account_params)
    @user_account.skip_password_validation!
    @user_account.skip_confirmation_notification!
    @user_account.confirm_email!
    super(account_type: CorporateAdminAccountUser.client_type, success_return_path: corporate_accounts_path)
  end
  
  def update
    super(account_type: CorporateAdminAccountUser.client_type, success_return_path: corporate_account_path(@corporate_profile) || corporate_accounts_path,
          params_to_update: user_account_params.except(:email))
  end
  
  private
  
  def corporate_settings_params
    params.require(:corporate_account_profile).permit(:business_name, :web_address, :street_address, :city,
                                              :zip, :state, :phone_number, :fax_number, :company_logo)
  end
  
  def user_accounts
    CorporateAdminAccountUser.select { |x| x.corporate_admin == current_user && x.account_type == CorporateAdminAccountUser.client_type }.map(&:user_account)
  end
  
  def user_account_params
    params.require(:user).permit(:email, :email_confirmation,
                                 user_profile_attributes: [ :first_name, :last_name,
                                                            :two_factor_phone_number,
                                                            :phone_number, :street_address_1,
                                                            :city, :state, :zip ])
  end
  
  def error_path(action)
    @path = ReturnPathService.error_path(current_user, current_user, params[:controller], action)
    corporate_account_error_breadcrumb_update
  end

  def success_path(path)
    ReturnPathService.success_path(current_user, current_user, path, path)
  end
end
