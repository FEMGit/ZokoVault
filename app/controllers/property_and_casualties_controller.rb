class PropertyAndCasualtiesController < AuthenticatedController
  before_action :set_property_and_casualty, only: [:show, :edit, :update, :destroy_provider]
  before_action :set_policy, :provider_by_policy, only: [:destroy]
  before_action :set_contacts, only: [:new, :create, :edit, :update]
  
  # Breadcrumbs navigation
  add_breadcrumb "Insurance", :insurance_path, :only => %w(new edit show index)
  before_action :set_details_crumbs, only: [:edit, :show]
  add_breadcrumb "Property & Casualty - Setup", :new_property_path, :only => %w(new)
  before_action :set_edit_crumbs, only: [:edit]
  
  def set_details_crumbs
    add_breadcrumb "#{@property_and_casualty.name}", property_path(@property_and_casualty)
  end
  
  def set_edit_crumbs
    add_breadcrumb "Property & Casualty - Setup", edit_property_path(@property_and_casualty)
  end

  # GET /properties
  # GET /properties.json
  def index
    @property_and_casualties = policy_scope(PropertyAndCasualty)
                               .each { |p| authorize p }
  end

  # GET /properties/1
  # GET /properties/1.json
  def show
    @insurance_card = @property_and_casualty
    @group_label = "Property & Casualty"
    @group_documents = DocumentService.new(:category => @insurance_card.category).get_insurance_documents(resource_owner, @group_label, params[:id])
    authorize @property_and_casualty
  end

  # GET /properties/new
  def new
    initialize_insurance_card
    authorize @insurance_card

    @errors = @insurance_card.errors
  end

  def initialize_insurance_card
    @insurance_card = PropertyAndCasualty.new(user: resource_owner)
    @insurance_card.policy.build
  end

  # GET /properties/1/edit
  def edit
    @insurance_card = @property_and_casualty
    @insurance_card.share_with_ids = @property_and_casualty.share_ids.collect { |x| Share.find(x).contact_id.to_s }

    authorize @property_and_casualty
  end

  # POST /properties
  # POST /properties.json
  def create
    @insurance_card = PropertyAndCasualty.new(property_and_casualty_params.merge(user_id: resource_owner.id))
    authorize @insurance_card
    PolicyService.fill_property_and_casualty_policies(policy_params, @insurance_card)
    respond_to do |format|
      if @insurance_card.save
        PolicyService.update_shares(@insurance_card.id, @insurance_card.share_with_ids, resource_owner.id)
        format.html { redirect_to insurance_path, flash: { success: 'Insurance was successfully created.' } }
        format.json { render :show, status: :created, location: @insurance_card }
      else
        format.html { render :new }
        format.json { render json: @insurance_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /properties/1
  # PATCH/PUT /properties/1.json
  def update
    @insurance_card = @property_and_casualty
    authorize @insurance_card
    PolicyService.fill_property_and_casualty_policies(policy_params, @insurance_card)
    respond_to do |format|
      if @insurance_card.update(property_and_casualty_params)
        PolicyService.update_shares(@insurance_card.id, @insurance_card.share_with_ids, resource_owner.id)
        format.html { redirect_to property_path(@insurance_card), flash: { success: 'Insurance was successfully updated.' } }
        format.json { render :show, status: :ok, location: @insurance_card }
      else
        format.html { render :edit }
        format.json { render json: @insurance_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /properties/1
  # DELETE /properties/1.json
  def destroy
    authorize @property_and_casualty
    @policy.destroy
    respond_to do |format|
      format.html { redirect_to :back || properties_url, notice: 'Insurance policy was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # DELETE /provider/1
  def destroy_provider
    authorize @property_and_casualty

    @property_and_casualty.destroy
    respond_to do |format|
      format.html { redirect_to insurance_path, notice: 'Insurance was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def provider_by_policy
    @property_and_casualty = PropertyAndCasualty.for_user(current_user).detect { |p| p.policy.any? { |x| x == @policy } }
  end
  
  def resource_owner
    @property_and_casualty.present? ? @property_and_casualty.user : current_user
  end

  def set_policy
    @policy = PropertyAndCasualtyPolicy.find(params[:id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_property_and_casualty
    @property_and_casualty = PropertyAndCasualty.find(params[:id])
  end

  def set_contacts
    contact_service = ContactService.new(:user => resource_owner)
    @contacts = contact_service.contacts
    @contacts_shareable = contact_service.contacts_shareable
  end

  def property_and_casualty_params
    params.require(:property_and_casualty).permit(:id, :name, :webaddress, :street_address_1, :city, :state, :zip, :phone, :fax, :contact_id, 
                                                  share_with_ids: [])
  end

  def policy_params
    policies = params[:property_and_casualty].select { |k, _v| k.starts_with?("policy_") }
    permitted_params = {}
    policies.keys.each do |policy_key|
      permitted_params[policy_key] = [:id, :policy_type, :insured_property, :policy_holder_id, :coverage_amount, :policy_number, 
                                      :broker_or_primary_contact_id, :notes]
    end
    policies.permit(permitted_params)
  end
end
