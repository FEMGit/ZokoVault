class FinancialInvestmentController < AuthenticatedController
  include SharedViewModule
  include SharedViewHelper
  before_action :set_financial_investment, only: [:show, :edit, :update, :destroy]
  before_action :set_financial_investment_provider, only: [:show, :edit, :update, :destroy, :set_documents]
  before_action :initialize_category_and_group, :set_documents, only: [:show]
  before_action :set_contacts, only: [:new, :edit]
  before_action :prepare_share_params, only: [:create, :update]
  
  # Breadcrumbs navigation
  add_breadcrumb "Financial Information", :financial_information_path, :only => %w(show new edit), if: :general_view?
  add_breadcrumb "Financial Information", :shared_view_financial_information_path, :only => %w(show new edit), if: :shared_view?
  before_action :set_add_crumbs, only: [:new]
  before_action :set_details_crumbs, only: [:edit, :show]
  before_action :set_edit_crumbs, only: [:edit]
  include BreadcrumbsCacheModule
  
  def set_add_crumbs
    add_breadcrumb "Financial Info - Add Other Investment or Debt", add_investment_path(@shared_user)
  end
  
  def set_details_crumbs
    add_breadcrumb "#{@financial_investment.name}", show_investment_path(@financial_investment, @shared_user)
  end
  
  def set_edit_crumbs
    add_breadcrumb "Financial Info - Add Other Investment or Debt", edit_investment_path(@financial_investment, @shared_user)
  end
  
  def new
    @financial_investment = FinancialInvestment.new(user: resource_owner,
                                                category: Category.fetch(Rails.application.config.x.FinancialInformationCategory.downcase))
    authorize @financial_investment
    set_viewable_contacts
  end
  
  def show
    authorize @financial_investment
    authorize @investment_provider
    session[:ret_url] = show_investment_url(@financial_investment, @shared_user)
  end
  
  def edit
    authorize @financial_investment
    @financial_investment.share_with_contact_ids = @investment_provider.share_with_contact_ids
    set_viewable_contacts
  end
  
  def create
    @financial_provider = FinancialProvider.new(user_id: resource_owner.id, name: property_params[:name])
    @financial_investment = FinancialInvestment.new(property_params.merge(user_id: resource_owner.id))
    @financial_provider.investments << @financial_investment
    authorize @financial_investment
    respond_to do |format|
      if @financial_provider.save
        FinancialInformationService.update_shares(@financial_provider, @financial_investment.share_with_contact_ids, nil, resource_owner, @financial_investment)
        @path = success_path(show_investment_url(@financial_investment), show_investment_url(@financial_investment, shared_user_id: resource_owner.id))
        format.html { redirect_to @path, flash: { success: 'Investment was successfully created.' } }
        format.json { render :show, status: :created, location: @financial_investment }
      else
        set_contacts
        error_path(:new)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout] }
        format.json { render json: @financial_investment.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    authorize @financial_investment
    @previous_share_with = @investment_provider.share_with_contact_ids
    respond_to do |format|
      if @financial_investment.update(property_params.merge(user_id: resource_owner.id))
        @investment_provider.update(name: property_params[:name])
        FinancialInformationService.update_shares(@investment_provider, @financial_investment.share_with_contact_ids,
                                                  @previous_share_with, resource_owner, @financial_investment)
        @path = success_path(show_investment_url(@financial_investment), show_investment_url(@financial_investment, shared_user_id: resource_owner.id))
        format.html { redirect_to @path, flash: { success: 'Investment was successfully updated.' } }
        format.json { render :show, status: :created, location: @financial_investment }
      else
        error_path(:edit)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout] }
        format.json { render json: @financial_investment.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    authorize @financial_investment
    @financial_investment.destroy
    @investment_provider.destroy
    respond_to do |format|
      format.html { redirect_to financial_information_path, notice: 'Investment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  
  def set_viewable_contacts
    contacts = category_subcategory_shares(@financial_investment, resource_owner)
    return unless contacts.present?
    @financial_investment.share_with_contact_ids |= ContactService.filter_contacts(contacts.map(&:contact_id))
  end
  
  def prepare_share_params
    return unless property_params[:share_with_contact_ids].present?
    viewable_shares = full_category_shares(Category.fetch(Rails.application.config.x.FinancialInformationCategory.downcase), resource_owner).map(&:contact_id).map(&:to_s)
    params[:financial_investment][:share_with_contact_ids] -= viewable_shares
    params[:financial_investment][:share_with_contact_ids].reject!(&:blank?)
  end
  
  def shared_user_params
    params.permit(:shared_user_id)
  end
  
  def resource_owner 
    if shared_user_params[:shared_user_id].present?
      User.find_by(id: params[:shared_user_id])
    else
      @investment_provider.present? ? @investment_provider.user : current_user
    end
  end
  
  def error_path(action)
    @path = ReturnPathService.error_path(resource_owner, current_user, params[:controller], action)
    @shared_user = ReturnPathService.shared_user(@path)
    @shared_category_names_full = ReturnPathService.shared_category_names(@path)
  end
  
  def success_path(common_path, shared_view_path)
    ReturnPathService.success_path(resource_owner, current_user, common_path, shared_view_path)
  end
  
  def set_financial_investment_provider
    @investment_provider = FinancialProvider.for_user(resource_owner).find(@financial_investment.empty_provider_id)
  end
  
  def set_financial_investment
    @financial_investment = FinancialInvestment.for_user(resource_owner).find(params[:id])
  end
  
  def set_documents
    @documents = Document.for_user(resource_owner).where(category: @category, financial_information_id: @investment_provider.id)
  end
  
  def initialize_category_and_group
    @category = Rails.application.config.x.FinancialInformationCategory
    @group = "Investment or Debt"
  end

  def property_params
    params.require(:financial_investment).permit(:id, :name, :web_address, :investment_type, :notes, :value, :owner_id, :city, :state, :zip, :address, :phone_number, :primary_contact_id, :category_id,
                                                 share_with_contact_ids: [])
  end
  
  def set_contacts
    contact_service = ContactService.new(:user => resource_owner)
    @contacts = contact_service.contacts
    @contacts_shareable = contact_service.contacts_shareable
  end
end
