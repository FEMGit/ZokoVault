class OnlineAccountsController < AuthenticatedController
  include SharedViewHelper
  include SharedViewModule
  
  before_action :set_contacts, only: [:new, :create, :edit, :update]
  before_action :set_online_account, only: [:edit, :update, :destroy]
  before_action :update_share_params, only: [:create, :update]
  
  # Breadcrumbs
  before_action :set_index_breadcrumbs, :only => %w(new edit index)
  before_action :set_new_crumbs, only: [:new]
  before_action :set_edit_crumbs, only: [:edit]
  include BreadcrumbsErrorModule
  include UserTrafficModule
  include CancelPathErrorUpdateModule
  
  def set_index_breadcrumbs
    add_breadcrumb "Online Accounts", online_accounts_path if general_view?
    add_breadcrumb "Online Accounts", shared_view_online_accounts_path(@shared_user) if shared_view?
  end

  def set_new_crumbs
    add_breadcrumb "Add Online Accounts", new_online_account_path(@shared_user)
  end

  def set_edit_crumbs
    add_breadcrumb "Edit Online Accounts", edit_online_account_path(@online_account, @shared_user)
  end
  
  def page_name
    case action_name
      when 'index'
        "Online Accounts"
      when 'new'
        "Add Online Account"
      when 'edit'
        online_account = OnlineAccount.for_user(resource_owner).find_by(id: params[:id])
        "Edit Online Account - #{online_account.website}"
    end
  end
  
  def index
    @category = Category.fetch(Rails.application.config.x.OnlineAccountCategory.downcase)
    @online_accounts = OnlineAccount.for_user(resource_owner)
    @online_accounts.each { |online_account| authorize online_account }
    @contacts_with_access = resource_owner.shares.categories.select { |share| share.shareable.eql? @category }.map(&:contact)
  end
  
  def new
    @online_account = OnlineAccount.new(user: resource_owner, category: Category.fetch(Rails.application.config.x.OnlineAccountCategory.downcase))
    authorize @online_account
    set_viewable_contacts
  end
  
  def edit
    authorize @online_account
    @password = @online_account.try(:decrypted_password)
    set_viewable_contacts
  end
  
  def create
    key = PerUserEncryptionKey.fetch_for(resource_owner)
    svc = PasswordService.for_per_user_key(key)
    encrypted_password = svc.encrypt_password(online_account_params[:password])
    @online_account = OnlineAccount.new(online_account_params.except(:password).merge(user_id: resource_owner.id,
                                                                                      password: encrypted_password,
                                                                                      category: Category.fetch(Rails.application.config.x.OnlineAccountCategory.downcase)))
    authorize @online_account
    respond_to do |format|
      if @online_account.save
        OnlineAccountService.update_shares(@online_account.id, resource_owner)
        format.html { redirect_to success_path, flash: { success: 'Account successfully created.' } }
        format.json { render :show, status: :created, location: @online_account }
      else
        error_path(:new)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout] }
        format.json { render json: @online_account.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    authorize @online_account
    key = PerUserEncryptionKey.fetch_for(@online_account.user)
    svc = PasswordService.for_per_user_key(key)
    encrypted_password = svc.encrypt_password(online_account_params[:password])
    respond_to do |format|
      if @online_account.update(online_account_params.except(:password).merge(password: encrypted_password))
        OnlineAccountService.update_shares(@online_account.id, resource_owner)
        format.html { redirect_to success_path, flash: { success: 'Account successfully updated.' } }
        format.json { render :show, status: :created, location: @online_account }
      else
        error_path(:edit)
        @online_account.update(online_account_params.except(:password).merge(password: encrypted_password))
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout] }
        format.json { render json: @online_account.errors , status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    authorize @online_account
    @online_account.destroy
    respond_to do |format|
      format.html { redirect_to online_accounts_url, notice: 'Account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def reveal_password
    online_account = OnlineAccount.for_user(resource_owner).find_by(id: reveal_password_params[:account_id])
    authorize online_account
    password = 
      if reveal_password_params.present? && online_account.present?
        online_account.decrypted_password
      else
        '**********'
      end
    render :json => password.to_json
  end
  
  private
  
  def set_online_account
    @online_account = OnlineAccount.for_user(resource_owner).find_by(id: params[:id])
  end
  
  def shared_user_params
    params.permit(:shared_user_id)
  end
  
  def reveal_password_params
    return nil unless params[:account_id].present?
    params.permit(:account_id)
  end
  
  def online_account_params
    params.require(:online_account).permit(:website, :username, :password, :notes, share_with_contact_ids: [])
  end
  
  def error_path(action)
    set_contacts
    @path = ReturnPathService.error_path(resource_owner, current_user, params[:controller], action)
    @shared_user = ReturnPathService.shared_user(@path)
    @shared_category_names_full = ReturnPathService.shared_category_names(@path)
    online_accounts_error_breadcrumb_update
  end

  def success_path
    shared_view_path = @shared_user.present? ? shared_view_online_accounts_path(@shared_user) : online_accounts_path
    ReturnPathService.success_path(resource_owner, current_user, online_accounts_path, shared_view_path)
  end
  
  def resource_owner
    if shared_user_params[:shared_user_id].present?
      User.find_by(id: params[:shared_user_id])
    else
      @online_account.present? ? @online_account.user : current_user
    end
  end
  
  def set_contacts
    contact_service = ContactService.new(:user => resource_owner)
    @contacts = contact_service.contacts
    @contacts_shareable = contact_service.contacts_shareable
  end
  
  def viewable_contacts
    category_subcategory_shares(@online_account, resource_owner).map(&:contact_id)
  end
  
  def set_viewable_contacts
    @online_account.share_with_contact_ids = viewable_contacts
  end
  
  def update_share_params
    if general_view? && params[:online_account]["share_with_contact_ids"].present?
      viewable_shares = full_category_shares(Category.fetch(Rails.application.config.x.OnlineAccountCategory.downcase), resource_owner).map(&:contact_id).map(&:to_s)
      params[:online_account]["share_with_contact_ids"] -= viewable_shares
    end
  end
end
