class HealthsController < AuthenticatedController
  before_action :set_health, only: [:show, :edit, :update, :destroy_provider]
  before_action :set_policy, only: [:destroy]
  before_action :set_contacts, only: [:new, :create, :edit, :update]

  # GET /healths
  # GET /healths.json
  def index
    @healths = policy_scope(Health).each { |h| authorize h }
  end

  # GET /healths/1
  # GET /healths/1.json
  def show
    @insurance_card = @health
    @grouop_label = "Health"
    @group_documents = DocumentService.new(:category => @insurance_card.category).get_group_documents(current_user, @grouop_label)

    authorize @health
  end

  # GET /healths/new
  def new
    @insurance_card = Health.new(user: current_user)
    @insurance_card.policy.build

    authorize @insurance_card
  end

  # GET /healths/1/edit
  def edit
    authorize @health

    @insurance_card = @health
    @insurance_card.share_with_ids = @health.share_ids.collect { |x| Share.find(x).contact_id.to_s }
  end

  # POST /healths
  # POST /healths.json
  def create
    @insurance_card = Health.new(health_params.merge(user_id: current_user.id))
    authorize @insurance_card
    PolicyService.fill_health_policies(policy_params, @insurance_card)
    respond_to do |format|
      if @insurance_card.save
        PolicyService.update_shares(@insurance_card.id, @insurance_card.share_with_ids)
        format.html { redirect_to insurance_path, notice: 'Health was successfully created.' }
        format.json { render :show, status: :created, location: @insurance_card }
      else
        format.html { render :new }
        format.json { render json: @insurance_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /healths/1
  # PATCH/PUT /healths/1.json
  def update
    authorize @health
    @insurance_card = @health
    PolicyService.fill_health_policies(policy_params, @insurance_card)
    respond_to do |format|
      if @insurance_card.update(health_params)
        PolicyService.update_shares(@insurance_card.id, @insurance_card.share_with_ids)
        format.html { redirect_to @health, notice: 'Health was successfully updated.' }
        format.json { render :show, status: :ok, location: @health }
      else
        format.html { render :edit }
        format.json { render json: @health.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /healths/1
  # DELETE /healths/1.json
  def destroy
    authorize @policy

    @policy.destroy
    respond_to do |format|
      format.html { redirect_to :back || healths_url, notice: 'Health was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # DELETE /provider/1
  def destroy_provider
    authorize @health

    @health.destroy
    respond_to do |format|
      format.html { redirect_to insurance_path, notice: 'PropertyAndCasualty was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_policy
      @policy = HealthPolicy.find(params[:id])
    end

    def set_health
      @health = Health.find(params[:id])
    end

    def set_contacts
      contact_service = ContactService.new(:user => current_user)
      @contacts = contact_service.contacts
      @contacts_shareable = contact_service.contacts_shareable
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def health_params
      params.require(:health).permit(:id, :name, :webaddress, :street_address_1, :city, :state, :zip, :phone, :fax, :contact_id, 
                                     share_with_ids: [])
    end

    def policy_params
      policies = params[:health].select { |k, _v| k.starts_with?("policy_") }
      permitted_params = {}
      policies.keys.each do |policy_key|
        permitted_params[policy_key] = [:id, :policy_type, :policy_number, :group_number, :policy_holder_id,
                                        :broker_or_primary_contact_id, :notes, insured_member_ids: []]
      end
      policies.permit(permitted_params)
    end
end
