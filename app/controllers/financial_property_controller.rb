class FinancialPropertyController < AuthenticatedController
  before_action :initialize_category_and_group, :set_documents, only: [:show]
  before_action :set_financial_property, only: [:show, :edit, :update, :destroy]
  before_action :set_contacts, only: [:new, :edit]
  
  def new
    @financial_property = FinancialProperty.new
  end
  
  def show
    session[:ret_url] = "#{financial_information_path}/property/#{params[:id]}"
  end
  
  def edit; end
  
  def create
    @financial_property = FinancialProperty.new(property_params.merge(user_id: current_user.id))
    respond_to do |format|
      if @financial_property.save
        format.html { redirect_to show_property_url(@financial_property), flash: { success: 'Property was successfully created.' } }
        format.json { render :show, status: :created, location: @financial_property }
      else
        set_contacts
        format.html { render :new }
        format.json { render json: @financial_property.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    respond_to do |format|
      if @financial_property.update(property_params.merge(user_id: current_user.id))
        format.html { redirect_to show_property_url(@financial_property), flash: { success: 'Property was successfully updated.' } }
        format.json { render :show, status: :created, location: @financial_property }
      else
        format.html { render :new }
        format.json { render json: @financial_property.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @financial_property.destroy
    respond_to do |format|
      format.html { redirect_to financial_information_path, notice: 'Property was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  
  def set_financial_property
    @financial_property = FinancialProperty.for_user(current_user).find(params[:id])
  end
  
  def set_documents
    @documents = Document.for_user(current_user).where(category: @category, group: @group)
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
    contact_service = ContactService.new(:user => current_user)
    @contacts = contact_service.contacts
    @contacts_shareable = contact_service.contacts_shareable
  end
end
