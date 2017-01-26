class FinancialInvestmentController < AuthenticatedController
  include SharedViewModule
  before_action :set_financial_investment, only: [:show, :edit, :update, :destroy]
  before_action :set_financial_investment_provider, only: [:show, :update, :destroy, :set_documents]
  before_action :initialize_category_and_group, :set_documents, only: [:show]
  before_action :set_contacts, only: [:new, :edit]
  
  # Breadcrumbs navigation
  add_breadcrumb "Financial Information", :financial_information_path, :only => %w(show new edit)
  add_breadcrumb "Financial Info - Add Other Investment or Debt", :add_investment_path, :only => %w(new)
  before_action :set_details_crumbs, only: [:edit, :show]
  before_action :set_edit_crumbs, only: [:edit]
  include BreadcrumbsCacheModule
  
  def set_details_crumbs
    add_breadcrumb "#{@financial_investment.name}", show_investment_path(@financial_investment)
  end
  
  def set_edit_crumbs
    add_breadcrumb "Financial Info - Add Other Investment or Debt", edit_investment_path(@financial_investment)
  end
  
  def new
    @financial_investment = FinancialInvestment.new(user: resource_owner)
    authorize @financial_investment
  end
  
  def show
    authorize @financial_investment
    authorize @investment_provider
    session[:ret_url] = show_investment_url(@financial_investment, @shared_user)
  end
  
  def edit
    authorize @financial_investment
  end
  
  def create
    @financial_provider = FinancialProvider.new(user_id: resource_owner.id, name: property_params[:name])
    @financial_investment = FinancialInvestment.new(property_params.merge(user_id: resource_owner.id))
    @financial_provider.investments << @financial_investment
    authorize @financial_investment
    respond_to do |format|
      if @financial_provider.save
        FinancialInformationService.update_shares(@financial_provider, @financial_investment.share_with_contact_ids, nil, resource_owner)
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
    @previous_share_with_ids = @financial_investment.share_with_contact_ids
    respond_to do |format|
      if @financial_investment.update(property_params.merge(user_id: resource_owner.id))
        @investment_provider.update(name: property_params[:name])
        FinancialInformationService.update_shares(@investment_provider, @financial_investment.share_with_contact_ids, @previous_share_with_ids, resource_owner)
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
    params.require(:financial_investment).permit(:id, :name, :web_address, :investment_type, :notes, :value, :owner_id, :city, :state, :zip, :address, :phone_number, :primary_contact_id,
                                                 share_with_contact_ids: [])
  end
  
  def set_contacts
    contact_service = ContactService.new(:user => resource_owner)
    @contacts = contact_service.contacts
    @contacts_shareable = contact_service.contacts_shareable
  end
end
