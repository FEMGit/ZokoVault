class FinancialAlternativeController < AuthenticatedController
  before_action :initialize_category_and_group, :set_documents, only: [:show]
  before_action :set_contacts, only: [:new, :edit]
  before_action :set_provider, only: [:show, :edit, :update, :destroy_provider]
  before_action :set_account, only: [:destroy]
  
  def new
    @financial_provider = FinancialProvider.new(user: resource_owner)
    @financial_alternative = FinancialAlternative.new
    @financial_provider.alternatives << @financial_alternative
    authorize @financial_provider
  end
  
  def show
    authorize @financial_provider
    session[:ret_url] = show_alternative_path(@financial_provider)
  end
  
  def edit
    authorize @financial_provider
  end
  
  def create
    @financial_provider = FinancialProvider.new(provider_params.merge(user_id: resource_owner.id))
    authorize @financial_provider
    FinancialInformationService.fill_alternatives(alternative_params, @financial_provider, resource_owner.id)
    respond_to do |format|
      if @financial_provider.save
        format.html { redirect_to show_alternative_url(@financial_provider), flash: { success: 'Alternative was successfully created.' } }
        format.json { render :show, status: :created, location: @financial_provider }
      else
        format.html { render :new }
        format.json { render json: @financial_provider.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    authorize @financial_provider
    FinancialInformationService.fill_alternatives(alternative_params, @financial_provider, resource_owner.id)
    respond_to do |format|
      if @financial_provider.update(provider_params)
        format.html { redirect_to show_alternative_path(@financial_provider), flash: { success: 'Alternative was successfully updated.' } }
        format.json { render :show, status: :ok, location: @financial_provider }
      else
        format.html { render :edit }
        format.json { render json: @financial_provider.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    financial_provider = FinancialProvider.find_by(id: @account.manager_id)
    authorize financial_provider
    @account.destroy
    respond_to do |format|
      format.html { redirect_to :back || financial_information_path, notice: 'Alternative investment was successfully destroyed.' }
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
  
  def resource_owner
    @financial_provider.present? ? @financial_provider.user : current_user
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
    @documents = Document.for_user(resource_owner).where(category: @category, group: @group)
  end

  
  def provider_params
    params.require(:financial_provider).permit(:id, :name, :web_address, :street_address, :city, :state, :zip, :phone_number, :fax_number, :primary_contact_id, 
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
