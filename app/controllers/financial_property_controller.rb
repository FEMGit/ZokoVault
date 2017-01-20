class FinancialPropertyController < AuthenticatedController
  before_action :set_financial_property, only: [:show, :edit, :update, :destroy]
  before_action :set_financial_property_provider, only: [:show, :update, :destroy, :set_documents]
  before_action :initialize_category_and_group, :set_documents, only: [:show]
  before_action :set_contacts, only: [:new, :edit]
  
  # Breadcrumbs navigation
  add_breadcrumb "Financial Information", :financial_information_path, :only => %w(show new edit)
  add_breadcrumb "Financial Info - Add Property", :add_property_path, :only => %w(new)
  before_action :set_details_crumbs, only: [:edit, :show]
  before_action :set_edit_crumbs, only: [:edit]
  
  def set_details_crumbs
    add_breadcrumb "#{@financial_property.name}", show_property_path(@financial_property)
  end
  
  def set_edit_crumbs
    add_breadcrumb "Financial Info - Add Property", edit_property_path(@financial_property)
  end
  
  def new
    @financial_property = FinancialProperty.new(user: resource_owner)
    authorize @financial_property
  end
  
  def show
    authorize @financial_property
    session[:ret_url] = "#{financial_information_path}/property/#{params[:id]}"
  end
  
  def edit
    authorize @financial_property
  end
  
  def create
    @financial_provider = FinancialProvider.new(user_id: resource_owner.id, name: property_params[:name])
    @financial_property = FinancialProperty.new(property_params.merge(user_id: resource_owner.id))
    @financial_provider.properties << @financial_property
    authorize @financial_property
    respond_to do |format|
      if @financial_provider.save
        FinancialInformationService.update_shares(@financial_provider, current_user, @financial_property.share_with_contact_ids)
        format.html { redirect_to show_property_url(@financial_property), flash: { success: 'Property was successfully created.' } }
        format.json { render :show, status: :created, location: @financial_property }
      else
        set_contacts
        format.html { render :new }
        format.json { render json: @financial_provider.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    authorize @financial_property
    respond_to do |format|
      if @financial_property.update(property_params.merge(user_id: resource_owner.id))
        @property_provider.update(name: property_params[:name])
        FinancialInformationService.update_shares(@property_provider, current_user, @financial_property.share_with_contact_ids)
        format.html { redirect_to show_property_url(@financial_property), flash: { success: 'Property was successfully updated.' } }
        format.json { render :show, status: :created, location: @financial_property }
      else
        format.html { render :new }
        format.json { render json: @financial_property.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    authorize @financial_property
    @financial_property.destroy
    @property_provider.destroy
    respond_to do |format|
      format.html { redirect_to financial_information_path, notice: 'Property was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  
  def resource_owner 
    @financial_property.present? ?  @financial_property.user : current_user
  end
  
  def set_financial_property_provider
    @property_provider = FinancialProvider.for_user(resource_owner).find(@financial_property.empty_provider_id)
  end
  
  def set_financial_property
    @financial_property = FinancialProperty.for_user(resource_owner).find(params[:id])
  end
  
  def set_documents
    @documents = Document.for_user(current_user).where(category: @category, financial_information_id: @property_provider.id)
  end
  
  def initialize_category_and_group
    @category = Rails.application.config.x.FinancialInformationCategory
    @group = "Property"
  end

  def property_params
    params.require(:financial_property).permit(:id, :name, :property_type, :notes, :value, :owner_id, :city, :state, :zip, :address, :primary_contact_id, 
                                               share_with_contact_ids: [])
  end
  
  def set_contacts
    contact_service = ContactService.new(:user => resource_owner)
    @contacts = contact_service.contacts
    @contacts_shareable = contact_service.contacts_shareable
  end
end
