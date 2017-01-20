class PowerOfAttorneysController < AuthenticatedController
  include SharedViewModule
  before_action :set_power_of_attorney, :set_document_params, only: [:show, :edit, :update, :destroy]
  before_action :set_contacts, only: [:new, :create, :edit, :update]
  before_action :set_ret_url
  before_action :set_document_params, only: [:index]
  
  # Breadcrumbs navigation
  add_breadcrumb "Wills Trusts & Legal", :estate_planning_path, :only => %w(new edit index)
  add_breadcrumb "Legal - Power of Attorney", :power_of_attorneys_path, :only => %w(edit index new)
  add_breadcrumb "Legal - Power of Attorney - Setup", :new_power_of_attorney_path, :only => %w(new)

  # GET /power_of_attorneys
  # GET /power_of_attorneys.json
  def index
    @power_of_attorneys = policy_scope(PowerOfAttorney)
                          .each { |p| authorize p }
    
    @power_of_attorneys = wills
    @power_of_attorneys.each { |x| authorize x }
    session[:ret_url] = @shared_user.present? ? shared_attorneys_path_path : power_of_attorneys_path
  end

  # GET /power_of_attorneys/1
  # GET /power_of_attorneys/1.json
  def show; end

  # GET /power_of_attorneys/new
  def new
    @vault_entry = PowerOfAttorneyBuilder.new.build
    @vault_entry.user = resource_owner
    @vault_entry.vault_entry_contacts.build

    authorize @vault_entry

    @power_of_attorneys = @vault_entries = PowerOfAttorney.for_user(resource_owner)
    return if @vault_entries.present?

    @vault_entries << @vault_entry
  end

  # GET /power_of_attorneys/1/edit
  def edit; end
  
  def set_document_params
    @group = "Legal"
    @category = Rails.application.config.x.WtlCategory
    @group_documents = DocumentService.new(:category => @category).get_group_documents(resource_owner, @group)
  end

  # POST /power_of_attorneys
  # POST /power_of_attorneys.json
  def create
    new_attorneys = WtlService.get_new_records(power_of_attorney_params)
    old_attorneys = WtlService.get_old_records(power_of_attorney_params)
    respond_to do |format|
      if !new_attorneys.empty? || !old_attorneys.empty?
        begin
          update_power_of_attorneys(new_attorneys, old_attorneys)
          format.html { redirect_to estate_planning_path, flash: { success: success_message(old_attorneys) } }
          format.json { render :show, status: :created, location: @power_of_attorney }
        rescue
          format.html { render :new }
          format.json { render json: @new_vault_entries.errors, status: :unprocessable_entity }
        end
      else
        format.html { render :new }
        format.json { render json: @new_vault_entries.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /power_of_attorneys/1
  # PATCH/PUT /power_of_attorneys/1.json
  def update
    respond_to do |format|
      if @power_of_attorney.update(power_of_attorney_params)
        format.html { redirect_to @power_of_attorney, flash: { success: 'Power of attorney was successfully updated.' } }
        format.json { render :show, status: :ok, location: @power_of_attorney }
      else
        format.html { render :edit }
        format.json { render json: @power_of_attorney.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /power_of_attorneys/1
  # DELETE /power_of_attorneys/1.json
  def destroy
    @power_of_attorney.destroy
    respond_to do |format|
      format.html { redirect_to :back || power_of_attorneys_url, notice: 'Power of attorney was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def get_powers_of_attorney_details
    render :json => WtlService.get_powers_of_attorney_details(PowerOfAttorney.for_user(resource_owner))
  end

  def set_ret_url
    session[:ret_url] = power_of_attorneys_path
  end

  def details; end

  private

  def resource_owner
    @power_of_attorney.present? ? @power_of_attorney.user : current_user
  end

  def set_contacts
    contact_service = ContactService.new(:user => resource_owner)
    @contacts = contact_service.contacts
    @contacts_shareable = contact_service.contacts_shareable
  end

  def current_wtl
    params[:attorney]
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_power_of_attorney
    @power_of_attorney = PowerOfAttorney.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def power_of_attorney_params
    attorneys = params.select { |k, _v| k.starts_with?("vault_entry_") }
    permitted_params = {}
    attorneys.keys.each do |attorney|
      permitted_params[attorney] = [:id, :agent_ids, :notes, :document_id, powers: PowerOfAttorney::POWERS, share_with_contact_ids: [], share_ids: []]
    end
    attorneys.permit(permitted_params)
  end
  
  def success_message(old_attorneys)
    return 'Power of Attorney was successfully created.' unless old_attorneys.any?
    'Power of Attorney was successfully updated.'
  end
  
  def update_power_of_attorneys(new_attorneys, old_attorneys)
    new_attorneys.each do |new_attorney_params|
      @new_vault_entries = PowerOfAttorneyBuilder.new(new_attorney_params.merge(user_id: resource_owner.id)).build 
      raise "error saving new power of attorney" unless @new_vault_entries.save
      WtlService.update_shares(@new_vault_entries.id, new_attorney_params[:share_with_contact_ids], resource_owner.id, PowerOfAttorney)
    end
    old_attorneys.each do |old_attorney|
      @old_vault_entries = PowerOfAttorneyBuilder.new(old_attorney.merge(user_id: resource_owner.id)).build
      authorize_save(@old_vault_entries)
      raise "error saving new power of attorney" unless @old_vault_entries.save
      WtlService.update_shares(@old_vault_entries.id, old_attorney[:share_with_contact_ids], resource_owner.id, PowerOfAttorney)
    end
  end
  
  def authorize_save(resource)
    authorize_ids = power_of_attorney_params.values.map { |x| x[:id].to_i }
    if authorize_ids.include? resource.id
      authorize resource
    end
  end
end
