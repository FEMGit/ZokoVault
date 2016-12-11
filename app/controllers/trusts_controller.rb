class TrustsController < AuthenticatedController
  before_action :set_trust, :set_document_params, only: [:show, :edit, :update, :destroy]
  before_action :set_contacts, only: [:new, :create, :edit, :update]
  before_action :set_ret_url
  before_action :set_document_params, only: [:index]

  # GET /trusts
  # GET /trusts.json
  def index
    @trusts = policy_scope(Trust).each { |t| authorize t }
  end

  # GET /trusts/1
  # GET /trusts/1.json
  def show; end

  # GET /trusts/new
  def new
    @vault_entry = TrustBuilder.new(type: 'trust').build
    @vault_entry.user = resource_owner
    @vault_entry.vault_entry_contacts.build

    authorize @vault_entry

    @vault_entries = Trust.for_user(resource_owner)
    return if @vault_entries.present?

    @vault_entries << @vault_entry
  end

  def create_empty_form
    @vault_entry = TrustBuilder.new(type: 'trust').build
    @vault_entry.vault_entry_contacts.build
    @vault_entries = Trust.for_user(resource_owner)
    @vault_entries << @vault_entry
    render :json => @vault_entries
  end

  # GET /trusts/1/edit
  def edit; end

  def set_document_params
    @group = "Trust"
    @category = Rails.application.config.x.WtlCategory
    @group_documents = DocumentService.new(:category => @category).get_group_documents(resource_owner, @group)
  end

  # POST /trusts
  # POST /trusts.json
  def create
    new_trusts = WtlService.get_new_records(trust_params)
    old_trusts = WtlService.get_old_records(trust_params)
    @vault_entries = []
    trusts = new_trusts + old_trusts
    respond_to do |format|
      if trusts.present?
        begin
          update_trusts(new_trusts, old_trusts)
          format.html { redirect_to estate_planning_path, notice: 'Trust was successfully created.' }
          format.json { render :show, status: :created, location: @trust }
        rescue
          @vault_entry = Trust.new
          @old_params.try(:each) { |trust| @vault_entries << trust }
          @new_params.try(:each) { |trust| @vault_entries << trust }
          format.html { render :new }
          format.json { render json: @errors, status: :unprocessable_entity }
        end
      else
        format.html { render :new }
        format.json { render json: @errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trusts/1
  # PATCH/PUT /trusts/1.json
  def update
    respond_to do |format|
      if @trust.update(trust_params)
        format.html { redirect_to @trust, notice: 'Trust was successfully updated.' }
        format.json { render :show, status: :ok, location: @trust }
      else
        format.html { render :edit }
        format.json { render json: @trust.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trusts/1
  # DELETE /trusts/1.json
  def destroy
    @trust.destroy
    respond_to do |format|
      format.html { redirect_to :back || trusts_url, notice: 'Trust was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def set_ret_url
    session[:ret_url] = trusts_path
  end

  def get_trusts_details
    render :json => WtlService.get_trusts_details(Trust.for_user(resource_owner))
  end

  private

  def resource_owner 
    @trust.present? ? @trust.user : current_user
  end

  def set_contacts
    contact_service = ContactService.new(:user => resource_owner)
    @contacts = contact_service.contacts
    @contacts_shareable = contact_service.contacts_shareable
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_trust
    @group_documents = Document.for_user(resource_owner).where(:group => @group)
    @trust = Trust.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def trust_params
    trusts = params.select { |k, _v| k.starts_with?("vault_entry_") }
    permitted_params = {}
    trusts.keys.each do |trust|
      permitted_params[trust] = [:id, :name, :agent_ids, :notes, :document_id, trustee_ids: [], successor_trustee_ids: [], share_ids: []]
    end
    trusts.permit(permitted_params)
  end

  def update_trusts(new_trusts, old_trusts)
    @errors = []
    @new_params = []
    @old_params = []
    old_trusts.each do |old_trust|
      @old_vault_entries = TrustBuilder.new(old_trust.merge(user_id: resource_owner.id)).build
      authorize @old_vault_entries
      @old_params << @old_vault_entries
      unless @old_vault_entries.save
        @errors << { id: old_trust[:id], error: @old_vault_entries.errors }
      end
    end
    new_trusts.each do |new_trust_params|
      @new_vault_entries = TrustBuilder.new(new_trust_params.merge(user_id: resource_owner.id)).build
      authorize @new_vault_entries
      if !@new_vault_entries.save
        @new_params << Trust.new(new_trust_params)
        @errors << { id: "", error: @new_vault_entries.errors }
      else
        @new_params << @new_vault_entries
      end
    end
    raise "error saving new trust" if @errors.any?
  end
end
