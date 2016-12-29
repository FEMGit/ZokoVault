class LifeAndDisabilitiesController < AuthenticatedController
  before_action :set_life, only: [:show, :edit, :update, :destroy_provider]
  before_action :set_policy, :provider_by_policy, only: [:destroy]
  before_action :set_contacts, only: [:new, :create, :edit, :update]
  
  # Breadcrumbs navigation
  add_breadcrumb "Insurance", :insurance_path, :only => %w(new edit show index)
  before_action :set_details_crumbs, only: [:edit, :show]
  add_breadcrumb "Life & Disability - Setup", :new_life_path, :only => %w(new)
  before_action :set_edit_crumbs, only: [:edit]
  
  def set_details_crumbs
    add_breadcrumb "#{@life_and_disability.name}", life_path(@life_and_disability)
  end
  
  def set_edit_crumbs
    add_breadcrumb "Life & Disability - Setup", edit_life_path(@life_and_disability)
  end

  # GET /lives
  # GET /lives.json
  def index
    @life_and_disabilities = policy_scope(LifeAndDisability)
                             .each { |l| authorize l }
  end

  # GET /lives/1
  # GET /lives/1.json
  def show
    authorize @life_and_disability

    @insurance_card = @life_and_disability
    @group_label = "Life & Disability"
    @group_documents = DocumentService.new(:category => @insurance_card.category.try(:name)).get_insurance_documents(resource_owner, @group_label, params[:id])
  end

  # GET /lives/new
  def new
    @insurance_card = LifeAndDisability.new(user: resource_owner)
    @insurance_card.policy.build

    authorize @insurance_card
  end

  # GET /lives/1/edit
  def edit
    authorize @life_and_disability

    @insurance_card = @life_and_disability
    @insurance_card.share_with_ids = @life_and_disability.share_ids.collect { |x| Share.find(x).contact_id.to_s }
  end

  # POST /lives
  # POST /lives.json
  def create
    @insurance_card = LifeAndDisability.new(life_params.merge(user_id: resource_owner.id))
    PolicyService.fill_life_policies(policy_params, @insurance_card)
    respond_to do |format|
      if @insurance_card.save
        PolicyService.update_shares(@insurance_card.id, @insurance_card.share_with_ids)
        format.html { redirect_to insurance_path, flash: { success: 'Insurance successfully created.' } }
        format.json { render :show, status: :created, location: @insurance_card }
      else
        format.html { render :new }
        format.json { render json: @insurance_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lives/1
  # PATCH/PUT /lives/1.json
  def update
    @insurance_card = @life_and_disability
    PolicyService.fill_life_policies(policy_params, @insurance_card)
    respond_to do |format|
      if @insurance_card.update(life_params)
        PolicyService.update_shares(@insurance_card.id, @insurance_card.share_with_ids)
        format.html { redirect_to life_path(@insurance_card), flash: { success: 'Insurance was successfully updated.' } }
        format.json { render :show, status: :ok, location: @insurance_card }
      else
        format.html { render :edit }
        format.json { render json: @insurance_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lives/1
  # DELETE /lives/1.json
  def destroy
    authorize @life_and_disability

    @policy.destroy
    respond_to do |format|
      format.html { redirect_to :back || lives_url, notice: 'Insurance policy was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # DELETE /provider/1
  def destroy_provider
    authorize @life_and_disability

    @life_and_disability.destroy
    respond_to do |format|
      format.html { redirect_to insurance_path, notice: 'Insurance was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  
  def provider_by_policy
    @life_and_disability = LifeAndDisability.for_user(current_user).detect { |p| p.policy.any? { |x| x == @policy } }
  end

  def resource_owner
    @life_and_disability.present? ? @life_and_disability.user : current_user
  end

  def set_life
    @life_and_disability = LifeAndDisability.find(params[:id])
  end

  def set_policy
    @policy = LifeAndDisabilityPolicy.find(params[:id])
  end

  def set_contacts
    contact_service = ContactService.new(:user => resource_owner)
    @contacts = contact_service.contacts
    @contacts_shareable = contact_service.contacts_shareable
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def life_params
    params.require(:life_and_disability).permit(:id, :name, :webaddress, :street_address_1, :city, :state, :zip, :phone, :fax, :contact_id, 
                                                share_with_ids: [])
  end

  def policy_params
    policies = params[:life_and_disability].select { |k, _v| k.starts_with?("policy_") }
    permitted_params = {}
    policies.keys.each do |policy_key|
      permitted_params[policy_key] = [:id, :policy_type, :policy_holder_id, :coverage_amount, :policy_number, :broker_or_primary_contact_id, :notes,
                                      primary_beneficiary_ids: [], secondary_beneficiary_ids: []]
    end
    policies.permit(permitted_params)
  end
end
