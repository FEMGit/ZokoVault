class WillsController < AuthenticatedController
  before_action :set_will, :set_document_params, only: [:show, :edit, :update, :destroy]
  before_action :set_contacts, only: [:new, :create, :edit, :update]
  before_action :set_ret_url
  before_action :set_document_params, only: [:index]

  # GET /wills
  # GET /wills.json
  def index
    @wills = policy_scope(Will).each { |w| authorize w }
  end

  # GET /wills/1
  # GET /wills/1.json
  def show; end

  # GET /wills/new
  def new
    @vault_entry = WillBuilder.new(type: 'will').build
    @vault_entry.user = resource_owner
    @vault_entry.vault_entry_contacts.build
    @vault_entry.vault_entry_beneficiaries.build

    authorize @vault_entry

    @wills = @vault_entries = Will.for_user(resource_owner)
    return unless @vault_entries.empty?

    @vault_entries << @vault_entry
  end

  # GET /wills/1/edit
  def edit; end

  def set_document_params
    @group = "Will"
    @category = Rails.application.config.x.WtlCategory
    @group_documents = DocumentService.new(:category => @category).get_group_documents(resource_owner, @group)
  end

  # POST /wills
  # POST /wills.json
  def create
    new_wills = WtlService.get_new_records(will_params)
    old_wills = WtlService.get_old_records(will_params)
    @vault_entries = []
    respond_to do |format|
      if new_wills.any? || old_wills.any?
        begin
          update_wills(new_wills, old_wills)
          format.html { redirect_to estate_planning_path, notice: 'Will was successfully created.' }
          format.json { render :show, status: :created, location: @will }
        rescue
          @vault_entry = Will.new
          @old_params.each { |will| @vault_entries << will }
          @new_params.each { |will| @vault_entries << will }
          format.html { render :new }
          format.json { render json: @errors, status: :unprocessable_entity }
        end
      else
        format.html { render :new }
        format.json { render json: @errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wills/1
  # PATCH/PUT /wills/1.json
  def update
    respond_to do |format|
      if @will.update(will_params)
        format.html { redirect_to @will, notice: 'Will was successfully updated.' }
        format.json { render :show, status: :ok, location: @will }
      else
        format.html { render :edit }
        format.json { render json: @will.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wills/1
  # DELETE /wills/1.json
  def destroy
    authorize @will
    @will.destroy
    respond_to do |format|
      format.html { redirect_to :back || wills_url, notice: 'Will was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def set_group
    @group = "Will"
  end

  def set_ret_url
    session[:ret_url] = wills_path
  end

  private

  def resource_owner 
    @will.present? ?  @will.user : current_user
  end

  def current_wtl
    params[:will]
  end

  def set_contacts
    contact_service = ContactService.new(:user => resource_owner)
    @contacts = contact_service.contacts
    @contacts_shareable = contact_service.contacts_shareable
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_will
    @will = Will.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def will_params
    wills = params.select { |k, _v| k.starts_with?("vault_entry_") }
    permitted_params = {}
    wills.keys.each do |will|
      permitted_params[will] = [:id, :title, :executor_id, :notes, :agent_ids, :document_id, primary_beneficiary_ids: [], secondary_beneficiary_ids: [], share_ids: [], share_with_contact_ids: []]
    end
    wills.permit(permitted_params)
  end

  def update_wills(new_wills, old_wills)
    @errors = []
    @new_params = []
    @old_params = []
    old_wills.each do |old_will|
      @old_vault_entries = WillBuilder.new(old_will.merge(user_id: current_user.id)).build
      authorize @old_vault_entries
      @old_params << @old_vault_entries
      unless @old_vault_entries.save
        @errors << { id: old_will[:id], error: @old_vault_entries.errors }
      end
    end
    new_wills.each do |new_will_params|
      @new_vault_entries = WillBuilder.new(new_will_params.merge(user_id: current_user.id)).build
      authorize @new_vault_entries
      if !@new_vault_entries.save
        @new_params << Will.new(new_will_params)
        @errors << { id: "", error: @new_vault_entries.errors }
      else
        @new_params << @new_vault_entries
      end
      raise "error saving new will" if @errors.any?
    end
    raise "error saving new will" if @errors.any?
  end
end
