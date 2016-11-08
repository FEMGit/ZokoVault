class HealthsController < AuthenticatedController
  before_action :set_health, only: [:show, :edit, :update, :destroy_provider]
  before_action :set_policy, only: [:destroy]
  before_action :set_contacts, only: [:new, :create, :edit, :update]

  # GET /healths
  # GET /healths.json
  def index
    @healths = Health.all
  end

  # GET /healths/1
  # GET /healths/1.json
  def show
    @insurance_card = @health
    @grouop_label = "Health"
    @group_documents = DocumentService.new(:category => @insurance_card.category).get_group_documents(current_user, @grouop_label)
  end

  # GET /healths/new
  def new
    @insurance_card = Health.new
    @insurance_card.policy << HealthPolicy.new
  end

  # GET /healths/1/edit
  def edit
    @insurance_card = @health
    @insurance_card.share_with_ids = @health.share_ids.collect{|x| Share.find(x).contact_id.to_s}
  end

  # POST /healths
  # POST /healths.json
  def create
    policies = policy_params
    policies.keys.each{|x| params[:health].delete(x)}
    @insurance_card = Health.new(health_params.merge(user_id: current_user.id))
    PolicyService.FillHealthPolicies(policies, @insurance_card)
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
    policies = policy_params
    policies.keys.each{|x| params[:health].delete(x)}
    @insurance_card = @health
    PolicyService.FillHealthPolicies(policies, @insurance_card)
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
    @policy.destroy
    respond_to do |format|
      format.html { redirect_to :back || healths_url, notice: 'Health was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # DELETE /provider/1
  def destroy_provider
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
      @contacts = Contact.for_user(current_user)
      @contacts_shareable = @contacts.reject { |c| c.emailaddress == current_user.email } 
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def health_params
      params.require(:health).permit!
    end
  
    def policy_params
      health_params.select{|k, v| k.starts_with?("policy_")}
    end
end
