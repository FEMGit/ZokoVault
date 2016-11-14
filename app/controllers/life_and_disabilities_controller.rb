class LifeAndDisabilitiesController < AuthenticatedController
  before_action :set_life, only: [:show, :edit, :update, :destroy_provider]
  before_action :set_policy, only: [:destroy]
  before_action :set_contacts, only: [:new, :create, :edit, :update]

  # GET /lives
  # GET /lives.json
  def index
    @life_and_disabilities = LifeAndDisability.for_user(current_user)
  end

  # GET /lives/1
  # GET /lives/1.json
  def show
    @insurance_card = @life_and_disability
    @grouop_label = "Life & Disability"
    @group_documents = DocumentService.new(:category => @insurance_card.category).get_group_documents(current_user, @grouop_label)
  end

  # GET /lives/new
  def new
    @insurance_card = LifeAndDisability.new
    @insurance_card.policy << LifeAndDisabilityPolicy.new
  end

  # GET /lives/1/edit
  def edit
    @insurance_card = @life_and_disability
    @insurance_card.share_with_ids = @life_and_disability.share_ids.collect { |x| Share.find(x).contact_id.to_s }
  end

  # POST /lives
  # POST /lives.json
  def create
    policies = policy_params
    policies.keys.each { |x| params[:life_and_disability].delete(x) }
    @insurance_card = LifeAndDisability.new(life_params.merge(user_id: current_user.id))
    PolicyService.fill_life_policies(policies, @insurance_card)
    respond_to do |format|
      if @insurance_card.save
        PolicyService.update_shares(@insurance_card.id, @insurance_card.share_with_ids)
        format.html { redirect_to insurance_path, notice: 'Life was successfully created.' }
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
    policies = policy_params
    policies.keys.each { |x| params[:life_and_disability].delete(x) }
    @insurance_card = @life_and_disability
    PolicyService.fill_life_policies(policies, @insurance_card)
    respond_to do |format|
      if @insurance_card.update(life_params)
        PolicyService.update_shares(@insurance_card.id, @insurance_card.share_with_ids)
        format.html { redirect_to life_path(@insurance_card), notice: 'Life was successfully updated.' }
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
    @policy.destroy
    respond_to do |format|
      format.html { redirect_to :back || lives_url, notice: 'Life was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  # DELETE /provider/1
  def destroy_provider
    @life_and_disability.destroy
    respond_to do |format|
      format.html { redirect_to insurance_path, notice: 'PropertyAndCasualty was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_life
      @life_and_disability = LifeAndDisability.find(params[:id])
    end

    def set_policy
      @policy = LifeAndDisabilityPolicy.find(params[:id])
    end

    def set_contacts
      contact_service = ContactService.new(:user => current_user)
      @contacts = contact_service.contacts
      @contacts_shareable = contact_service.contacts_shareable
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def life_params
      params.fetch(:life_and_disability).permit!
    end
  
    def policy_params
      life_params.select { |k, _v| k.starts_with?("policy_") }
    end
end
