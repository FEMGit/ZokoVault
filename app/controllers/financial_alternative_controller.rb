class FinancialAlternativeController < AuthenticatedController
  include SharedViewModule
  include SharedViewHelper
  include BackPathHelper
  include SanitizeModule
  before_action :set_provider, only: [:show, :edit, :update, :destroy_provider, :set_documents]
  before_action :initialize_category_and_group, :set_documents, only: [:show]
  before_action :set_contacts, only: [:new, :edit]
  before_action :set_account, only: [:destroy]
  before_action :prepare_share_params, only: [:create, :update]
  
  # Breadcrumbs navigation
  add_breadcrumb "Financial Information", :financial_information_path, :only => %w(show new edit), if: :general_view?
  add_breadcrumb "Financial Information", :shared_view_financial_information_path, :only => %w(show new edit), if: :shared_view?
  before_action :set_add_crumbs, only: [:new]
  before_action :set_details_crumbs, only: [:edit, :show]
  before_action :set_edit_crumbs, only: [:edit]
  include BreadcrumbsCacheModule
  
  def set_add_crumbs
    add_breadcrumb "Alternative - Add Investment", add_alternative_path(@shared_user)
  end
  
  def set_details_crumbs
    add_breadcrumb "#{@financial_provider.name}", show_alternative_path(@financial_provider, @shared_user)
  end
  
  def set_edit_crumbs
    add_breadcrumb "Alternative - Add Investment", edit_alternative_path(@financial_provider, @shared_user)
  end
  
  def new
    @financial_provider = FinancialProvider.new(user: resource_owner,
                                                category: Category.fetch(Rails.application.config.x.FinancialInformationCategory.downcase))
    @financial_alternative = FinancialAlternative.new
    @financial_provider.alternatives << @financial_alternative
    authorize @financial_provider
    set_viewable_contacts
  end
  
  def show
    authorize @financial_provider
    session[:ret_url] = show_alternative_path(@financial_provider, @shared_user)
  end
  
  def edit
    authorize @financial_provider
    set_viewable_contacts
  end
  
  def create
    @financial_provider = FinancialProvider.new(provider_params.merge(user_id: resource_owner.id))
    authorize @financial_provider
    FinancialInformationService.fill_alternatives(alternative_params, @financial_provider, resource_owner.id)
    respond_to do |format|
      if @financial_provider.save
        FinancialInformationService.update_shares(@financial_provider, @financial_provider.share_with_contact_ids, nil, resource_owner)
        @path = success_path(show_alternative_url(@financial_provider), show_alternative_url(@financial_provider, shared_user_id: resource_owner.id))
        format.html { redirect_to @path, flash: { success: 'Alternative was successfully created.' } }
        format.json { render :show, status: :created, location: @financial_provider }
      else
        error_path(:new)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout] }
        format.json { render json: @financial_provider.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    authorize @financial_provider
    @previous_share_with = @financial_provider.share_with_contact_ids
    FinancialInformationService.fill_alternatives(alternative_params, @financial_provider, resource_owner.id)
    respond_to do |format|
      if @financial_provider.update(provider_params)
        FinancialInformationService.update_shares(@financial_provider, @financial_provider.share_with_contact_ids, @previous_share_with, resource_owner)
        @path = success_path(show_alternative_url(@financial_provider), show_alternative_url(@financial_provider, shared_user_id: resource_owner.id))
        format.html { redirect_to @path, flash: { success: 'Alternative was successfully updated.' } }
        format.json { render :show, status: :ok, location: @financial_provider }
      else
        error_path(:edit)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout] }
        format.json { render json: @financial_provider.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    financial_provider = FinancialProvider.find_by(id: @account.manager_id)
    authorize financial_provider
    @account.destroy
    respond_to do |format|
      format.html { redirect_to back_path || financial_information_path, notice: 'Alternative investment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # DELETE /provider/1
  def destroy_provider
    authorize @financial_provider
    @financial_provider.destroy
    respond_to do |format|
      format.html { redirect_to financial_information_path, notice: 'Manager was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  private
  
  def set_viewable_contacts
    contacts = category_subcategory_shares(@financial_provider, resource_owner)
    return unless contacts.present?
    @financial_provider.share_with_contact_ids |= ContactService.filter_contacts(contacts.map(&:contact_id))
  end
  
  def prepare_share_params
    return unless provider_params[:share_with_contact_ids].present?
    viewable_shares = full_category_shares(Category.fetch(Rails.application.config.x.FinancialInformationCategory.downcase), resource_owner).map(&:contact_id).map(&:to_s)
    params[:financial_provider][:share_with_contact_ids] -= viewable_shares
    params[:financial_provider][:share_with_contact_ids].reject!(&:blank?)
  end
  
  def shared_user_params
    params.permit(:shared_user_id)
  end
  
  def error_path(action)
    @path = ReturnPathService.error_path(resource_owner, current_user, params[:controller], action)
    @shared_user = ReturnPathService.shared_user(@path)
    @shared_category_names_full = ReturnPathService.shared_category_names(@path)
  end
  
  def success_path(common_path, shared_view_path)
    ReturnPathService.success_path(resource_owner, current_user, common_path, shared_view_path)
  end

  def resource_owner 
    if shared_user_params[:shared_user_id].present?
      User.find_by(id: params[:shared_user_id])
    else
      @financial_provider.present? ? @financial_provider.user : current_user
    end
  end
  
  def initialize_category_and_group
    @category = Rails.application.config.x.FinancialInformationCategory
    @group = "Alternative Investment"
  end
  
  def set_account
    @account = FinancialAlternative.for_user(resource_owner).find(params[:id])
  end
  
  def set_provider
    @financial_provider = FinancialProvider.for_user(resource_owner).find(params[:id])
  end
  
  def set_documents
    @documents = Document.for_user(resource_owner).where(category: @category, financial_information_id: @financial_provider.id)
  end

  
  def provider_params
    params.require(:financial_provider).permit(:id, :name, :web_address, :street_address, :city, :state, :zip, :phone_number, :fax_number, :primary_contact_id, :category_id,
                                               share_with_contact_ids: [])
  end
  
  def alternative_params
    alternatives = params[:financial_provider].select { |k, _v| k.starts_with?("alternative_") }
    permitted_params = {}
    alternatives.keys.each do |alternative|
      permitted_params[alternative] = [:id, :alternative_type, :owner_id, :commitment, :total_calls, :total_distributions,
                                       :notes, :current_value, :primary_contact_id, :name]
    end
    alternatives.permit(permitted_params)
  end
  
  def set_contacts
    contact_service = ContactService.new(:user => resource_owner)
    @contacts = contact_service.contacts
    @contacts_shareable = contact_service.contacts_shareable
  end
end
