class PropertyAndCasualtiesController < AuthenticatedController
  before_action :set_property_and_casualty, only: [:show, :edit, :update, :destroy_provider]
  before_action :set_policy, only: [:destroy]
  before_action :set_contacts, only: [:new, :create, :edit, :update]

  # GET /properties
  # GET /properties.json
  def index
    @property_and_casualties = PropertyAndCasualty.all
  end

  # GET /properties/1
  # GET /properties/1.json
  def show
    @insurance_card = @property_and_casualty
    @grouop_label = "Property & Casualty"
    @group_documents = DocumentService.new(:category => @insurance_card.category).get_group_documents(current_user, @grouop_label)
  end

  # GET /properties/new
  def new
    initialize_insurance_card
    @errors = @insurance_card.errors
  end
  
  def initialize_insurance_card
    @insurance_card = PropertyAndCasualty.new
    @insurance_card.policy << PropertyAndCasualtyPolicy.new
  end

  # GET /properties/1/edit
  def edit
    @insurance_card = @property_and_casualty
    @insurance_card.share_with_ids = @property_and_casualty.share_ids.collect { |x| Share.find(x).contact_id.to_s }
  end
  
  # POST /properties
  # POST /properties.json
  def create
    policies = policy_params
    policies.keys.each { |x| params[:property_and_casualty].delete(x) }
    @insurance_card = PropertyAndCasualty.new(property_and_casualty_params.merge(user_id: current_user.id))
    PolicyService.fill_property_and_casualty_policies(policies, @insurance_card)
    respond_to do |format|
      if @insurance_card.save
        PolicyService.update_shares(@insurance_card.id, @insurance_card.share_with_ids)
        format.html { redirect_to insurance_path, notice: 'PropertyAndCasualty was successfully created.' }
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
    policies = policy_params
    policies.keys.each { |x| params[:property_and_casualty].delete(x) }
    @insurance_card = @property_and_casualty
    PolicyService.fill_property_and_casualty_policies(policies, @insurance_card)
    respond_to do |format|
      if @insurance_card.update(property_and_casualty_params)
        PolicyService.update_shares(@insurance_card.id, @insurance_card.share_with_ids)
        format.html { redirect_to property_path(@insurance_card), notice: 'PropertyAndCasualty was successfully updated.' }
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
    @policy.destroy
    respond_to do |format|
      format.html { redirect_to :back || properties_url, notice: 'PropertyAndCasualty was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  # DELETE /provider/1
  def destroy_provider
    @property_and_casualty.destroy
    respond_to do |format|
      format.html { redirect_to insurance_path, notice: 'PropertyAndCasualty was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_policy
      @policy = PropertyAndCasualtyPolicy.find(params[:id])
    end
    
    # Use callbacks to share common setup or constraints between actions.
    def set_property_and_casualty
      @property_and_casualty = PropertyAndCasualty.find(params[:id])
    end

    def set_contacts
      @contacts = Contact.for_user(current_user)
      @contacts_shareable = @contacts.reject { |c| c.emailaddress == current_user.email } 
    end

    def property_and_casualty_params
      params.require(:property_and_casualty).permit!
    end

    def policy_params
      property_and_casualty_params.select { |k, _v| k.starts_with?("policy_") }
    end
end
