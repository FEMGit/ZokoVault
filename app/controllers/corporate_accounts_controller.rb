class CorporateAccountsController < AuthenticatedController
  before_action :redirect_unless_corporate_admin
  before_action :set_corporate_contact_by_user_profile, only: [:edit, :show]
  before_action :set_corporate_user_by_user_profile, only: [:edit, :update]

  before_action :set_index_breadcrumbs, :only => %w(new edit show)
  before_action :set_details_crumbs, only: [:edit, :show]
  before_action :set_new_crumbs, only: [:new]
  before_action :set_edit_crumbs, only: [:edit]
  include BreadcrumbsErrorModule
  include UserTrafficModule
  
  def set_index_breadcrumbs
    add_breadcrumb "Corporate Account", corporate_accounts_path
  end

  def set_new_crumbs
    add_breadcrumb "Add Account", new_corporate_account_path
  end
  
  def set_details_crumbs
    add_breadcrumb "#{@corporate_contact.try(:name)} Details", corporate_account_path(@corporate_contact.user_profile_id)
  end
  
  def set_edit_crumbs
    add_breadcrumb "Add User Account", edit_corporate_account_path(@corporate_contact.user_profile_id)
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
    corporate_users_emails = CorporateAdminAccountUser.select { |x| x.corporate_admin == current_user }
                                                      .map(&:user_account).map(&:email).map(&:downcase)
    @corporate_contacts = Contact.for_user(current_user).select { |c| corporate_users_emails.include? c.emailaddress.downcase }
  end
  
  def show; end
  
  def new
    @user_account = User.new(user_profile: UserProfile.new)
  end
  
  def edit; end
  
  def create
    @user_account = User.new(user_account_params)
    @user_account.skip_password_validation!
    @user_account.skip_confirmation_notification!
    respond_to do |format|
      if @user_account.save
        CorporateAdminAccountUser.create(corporate_admin: current_user, user_account: @user_account)
        create_associated_contact
        format.html { redirect_to success_path(corporate_accounts_path), flash: { success: 'User Account successfully created.' } }
        format.json { render :show, status: :created, location: @user_account }
      else
        error_path(:new)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout], locals: @path[:locals] }
        format.json { render json: @user_accounts.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    respond_to do |format|
      if @user_account.update(user_account_params.except(:email))
        corporate_profile = Contact.for_user(current_user).find_by(emailaddress: @user_account.email).user_profile
        update_associated_contacts
        format.html { redirect_to success_path(corporate_account_path(corporate_profile) || corporate_accounts_path), flash: { success: 'User Account successfully updated.' } }
        format.json { render :show, status: :created, location: @user_account }
      else
        error_path(:edit)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout], locals: @path[:locals] }
        format.json { render json: @user_accounts.errors, status: :unprocessable_entity }
      end
    end
  end
  
  private
  
  def create_associated_contact
    admin_contact = Contact.new(emailaddress: @user_account.email,
                                user_id: current_user.id,
                                user_profile: @user_account.user_profile)
    admin_contact.save
    user_profile = admin_contact.user_profile
    update_contact_attributes(admin_contact, user_profile)
  end
  
  def update_associated_contacts
    admin_contact = Contact.where(emailaddress: @user_account.email, user_id: current_user.id).first
    user_profile = admin_contact.user_profile
    update_contact_attributes(admin_contact, user_profile)
  end
  
  def update_contact_attributes(contact, user_profile)
    contact.update_attributes(
      firstname: user_profile.first_name,
      lastname: user_profile.last_name,
      phone: user_profile.two_factor_phone_number,
      contact_type: nil,
      relationship: 'Account Owner',
      beneficiarytype: nil,
      birthdate: user_profile.date_of_birth,
      address: [user_profile.street_address_1, user_profile.street_address_2].compact.join(" "),
      zipcode: user_profile.zip,
      state: user_profile.state,
      city: user_profile.city
    )
  end
  
  def set_corporate_contact_by_user_profile
    user_profile = UserProfile.find_by(id: params[:id])
    return unless user_profile.present?
    return unless user_accounts.include? user_profile.user
    @corporate_contact = Contact.where(user_profile_id: user_profile.id, user_id: current_user.id).first
  end
  
  def set_corporate_user_by_user_profile
    return unless current_user.corporate_admin
    user_id = UserProfile.find_by(id: params[:id]).user_id
    user = User.find_by(id: user_id)
    return unless user_accounts.include? user
    @user_account = user
  end
  
  def user_accounts
    CorporateAdminAccountUser.select { |x| x.corporate_admin == current_user }.map(&:user_account)
  end
  
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

  def success_path(path)
    ReturnPathService.success_path(current_user, current_user, path, path)
  end
  
  def redirect_unless_corporate_admin
    redirect_to root_path unless current_user.present? && current_user.corporate_admin
  end
end
