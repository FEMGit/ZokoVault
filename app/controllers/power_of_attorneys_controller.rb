class PowerOfAttorneysController < AuthenticatedController
  include SharedViewModule
  before_action :set_power_of_attorney, :set_document_params, only: [:show, :edit, :update, :destroy]
  before_action :set_contacts, only: [:new, :create, :edit, :update]
  before_action :set_previous_shared_with, only: [:create]
  before_action :set_ret_url
  before_action :set_document_params, only: [:index]
  
  # Breadcrumbs navigation
  add_breadcrumb "Wills Trusts & Legal", :estate_planning_path, :only => %w(new edit index)
  add_breadcrumb "Legal - Power of Attorney", :power_of_attorneys_path, :only => %w(edit index new)
  add_breadcrumb "Legal - Power of Attorney - Setup", :new_power_of_attorney_path, :only => %w(new)
  include BreadcrumbsCacheModule

  # GET /power_of_attorneys
  # GET /power_of_attorneys.json
  def index
    @power_of_attorneys = attorneys
    @power_of_attorneys.each { |x| authorize x }
    session[:ret_url] = @shared_user.present? ? shared_power_of_attorneys_path : power_of_attorneys_path
  end

  # GET /power_of_attorneys/1
  # GET /power_of_attorneys/1.json
  def show; end

  # GET /power_of_attorneys/new
  def new
    @vault_entry = PowerOfAttorneyBuilder.new.build
    @vault_entry.user = resource_owner
    @vault_entry.vault_entry_contacts.build


    @vault_entries = attorneys
    @vault_entries.each { |x| authorize x }
    return unless @vault_entries.empty?

    @vault_entries << @vault_entry
    @vault_entries.each { |x| authorize x }
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
          format.html { redirect_to success_path(old_attorneys), flash: { success: success_message(old_attorneys) } }
          format.json { render :show, status: :created, location: @power_of_attorney }
        rescue
          error_path(:new)
          format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout], locals: @path[:locals] }
          format.json { render json: @new_vault_entries.errors, status: :unprocessable_entity }
        end
      else
        error_path(:new)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout], locals: @path[:locals] }
        format.json { render json: @new_vault_entries.errors, status: :unprocessable_entity }
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
  
  def attorneys
    return PowerOfAttorney.for_user(resource_owner) unless @shared_user
    return @shares.map(&:shareable).select { |resource| resource.is_a? PowerOfAttorney } unless @category_shared
    PowerOfAttorney.for_user(@shared_user)
  end
  
  def error_path(action)
    @path = ReturnPathService.error_path(resource_owner, current_user, params[:controller], action)
    @shared_user = ReturnPathService.shared_user(@path)
    @shared_category_names_full = ReturnPathService.shared_category_names(@path)
  end
  
  def success_path(old_attorneys)
    return ReturnPathService.success_path(resource_owner, current_user, estate_planning_path, shared_view_estate_planning_path(shared_user_id: resource_owner.id)) unless old_attorneys.any?
    ReturnPathService.success_path(resource_owner, current_user, power_of_attorneys_path, shared_power_of_attorneys_path(shared_user_id: resource_owner.id))
  end

  def resource_owner 
    if shared_user_params[:shared_user_id].present?
      User.find_by(id: params[:shared_user_id])
    else
      @power_of_attorney.present? ? @power_of_attorney.user : current_user
    end
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
  
  def shared_user_params
    params.permit(:shared_user_id)
  end
  
  def attorneys_shared_with_uniq_param
    power_of_attorney_params.values.map { |x| x["share_with_contact_ids"] }.flatten.uniq.reject(&:blank?)
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
    @new_params, @old_params = [], []
    new_attorneys.each do |new_attorney_params|
      @new_vault_entries = PowerOfAttorneyBuilder.new(new_attorney_params.merge(user_id: resource_owner.id)).build 
      raise "error saving new power of attorney" unless @new_vault_entries.save
      @new_params << @new_vault_entries
      WtlService.update_shares(@new_vault_entries.id, new_attorney_params[:share_with_contact_ids], resource_owner.id, PowerOfAttorney)
    end
    old_attorneys.each do |old_attorney|
      @old_vault_entries = PowerOfAttorneyBuilder.new(old_attorney.merge(user_id: resource_owner.id)).build
      authorize_save(@old_vault_entries)
      raise "error saving new power of attorney" unless @old_vault_entries.save
      @old_params << @old_vault_entries
      WtlService.update_shares(@old_vault_entries.id, old_attorney[:share_with_contact_ids], resource_owner.id, PowerOfAttorney)
    end
    ShareInheritanceService.update_document_shares(PowerOfAttorney, (@old_params + @new_params).map(&:id), resource_owner.id, @previous_shared_with, attorneys_shared_with_uniq_param, 'Legal')
  end
  
  def authorize_save(resource)
    authorize_ids = power_of_attorney_params.values.map { |x| x[:id].to_i }
    if authorize_ids.include? resource.id
      authorize resource
    end
  end
  
  def set_previous_shared_with
    old_attorneys = WtlService.get_old_records(power_of_attorney_params)
    old_attorney_ids = old_attorneys.map { |x| x["id"] }.flatten.uniq.reject(&:blank?)
    @previous_shared_with = PowerOfAttorney.find(old_attorney_ids).map(&:share_with_contact_ids).flatten.uniq
  end
end
