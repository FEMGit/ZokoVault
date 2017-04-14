class PowerOfAttorneysController < AuthenticatedController
  include SharedViewModule
  include SharedViewHelper
  include BackPathHelper
  include SanitizeModule
  before_action :set_power_of_attorney_contact, only: [:show, :edit, :update, :destroy_power_of_attorney_contact]
  before_action :set_power_of_attorney, :set_document_params, only: [:destroy]
  before_action :set_contacts, only: [:new, :create, :edit, :update, :new_wills_poa]
  before_action :set_previous_shared_with, only: [:update]
  before_action :update_share_params, only: [:create, :update]
  before_action :set_documents, only: [:show]
  before_action :set_document_params, only: [:index]
  
  # General Breadcrumbs
  add_breadcrumb "Wills Trusts & Legal", :estate_planning_path, :only => %w(new index), if: :general_view?
  add_breadcrumb "Legal - Power of Attorney", :power_of_attorneys_path, :only => %w(index new), if: :general_view?
  add_breadcrumb "Legal - Power of Attorney - Setup", :new_power_of_attorney_path, :only => %w(new), if: :general_view?
  
  add_breadcrumb "Wills & Powers of Attorney", :wills_powers_of_attorney_path, :only => %w(new_wills_poa edit show), if: :general_view?
  add_breadcrumb "Wills & Powers of Attorney", :shared_view_wills_powers_of_attorney_path, if: :shared_view?
  before_action :set_details_crumbs, only: [:edit, :show]
  before_action :set_new_crumbs, only: [:new_wills_poa]
  before_action :set_edit_crumbs, only: [:edit]
  # Shared BreadCrumbs
  add_breadcrumb "Wills Trusts & Legal", :shared_view_estate_planning_path, :only => %w(new index), if: :shared_view?
  add_breadcrumb "Legal - Power of Attorney", :shared_power_of_attorneys_path, :only => %w(index new), if: :shared_view?
  add_breadcrumb "Legal - Power of Attorney - Setup", :shared_new_power_of_attorneys_path, :only => %w(new), if: :shared_view?
  include BreadcrumbsCacheModule
  include UserTrafficModule

  def set_new_crumbs
    add_breadcrumb "Power of Attorney - Setup", wills_poa_new_power_of_attorney_path(@shared_user)
  end
  
  def set_details_crumbs
    add_breadcrumb "Power of Attorney - #{@power_of_attorney_contact.contact.try(:name)}", power_of_attorney_path(@power_of_attorney_contact, @shared_user)
  end
  
  def set_edit_crumbs
    add_breadcrumb "Power of Attorney - Setup", edit_power_of_attorney_path(@power_of_attorney_contact, @shared_user)
  end
  
  def page_name
    case action_name
      when 'index'
        return "Power of Attorneys"
      when 'new'
        return "Power of Attorneys - Setup"
    end
  end

  # GET /power_of_attorneys
  # GET /power_of_attorneys.json
  def index
    @power_of_attorneys = attorneys
    @power_of_attorneys.each { |x| authorize x }
    session[:ret_url] = @shared_user.present? ? shared_power_of_attorneys_path : power_of_attorneys_path
  end
  
  def new_wills_poa
    @power_of_attorney = PowerOfAttorneyBuilder.new.build
    @power_of_attorney.user = resource_owner
    @power_of_attorney.vault_entry_contacts.build

    @power_of_attorney_contact = PowerOfAttorneyContact.new(user: resource_owner,
      category: Category.fetch(Rails.application.config.x.WillsPoaCategory.downcase))
    @power_of_attorney_contact.power_of_attorneys << @power_of_attorney
    authorize @power_of_attorney_contact
    set_viewable_contacts_global
  end
  
  def edit
    authorize @power_of_attorney_contact
    set_viewable_contacts_global
  end
  
  def show
    authorize @power_of_attorney_contact
    session[:ret_url] = power_of_attorney_path(@power_of_attorney_contact, @shared_user)
  end

  # GET /power_of_attorneys/new
  def new
    @vault_entry = PowerOfAttorneyBuilder.new.build
    @vault_entry.user = resource_owner
    @vault_entry.vault_entry_contacts.build

    @vault_entries = attorneys
    @vault_entries.each { |x| authorize x }
    set_viewable_contacts
    return unless @vault_entries.empty?

    @vault_entries << @vault_entry
    @vault_entries.each { |x| authorize x }
  end
  
  def set_document_params
    @group = "Legal"
    @category = Rails.application.config.x.WtlCategory
    @group_documents = DocumentService.new(:category => @category).get_group_documents(resource_owner, @group)
  end
  
  def set_documents
    @category = Rails.application.config.x.WillsPoaCategory
    @group_documents = Document.for_user(resource_owner).where(:category => @power_of_attorney_contact.category.name,
      :card_document_id => CardDocument.power_of_attorney(@power_of_attorney_contact.id).id)
  end

    # POST /power_of_attorneys
  # POST /power_of_attorneys.json
  def create
    @power_of_attorney_contact = PowerOfAttorneyContact.new(power_of_attorney_contact_params.merge(user_id: resource_owner.id, category: Category.fetch(Rails.application.config.x.WillsPoaCategory.downcase)))
    authorize @power_of_attorney_contact
    WtlService.fill_power_of_attorneys(power_of_attorney_params, @power_of_attorney_contact)
    respond_to do |format|
      if @power_of_attorney_contact.save
        WtlService.update_shares(@power_of_attorney_contact.id, @power_of_attorney_contact.share_with_contact_ids, resource_owner.id, PowerOfAttorneyContact)
        WtlService.fill_agents(@power_of_attorney_contact, power_of_attorney_params)
        @path = success_path(power_of_attorney_path(@power_of_attorney_contact), power_of_attorney_path(@power_of_attorney_contact, resource_owner))
        format.html { redirect_to @path, flash: { success: 'Power of Attorney successfully created.' } }
        format.json { render :show, status: :created, location: @insurance_card }
      else
        error_path(:new)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout] }
        format.json { render json: @insurance_card.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    authorize @power_of_attorney_contact
    WtlService.fill_power_of_attorneys(power_of_attorney_params, @power_of_attorney_contact)
    respond_to do |format|
      if @power_of_attorney_contact.update(power_of_attorney_contact_params)
        WtlService.update_shares(@power_of_attorney_contact.id, @power_of_attorney_contact.share_with_contact_ids, resource_owner.id, PowerOfAttorneyContact)
        WtlService.fill_agents(@power_of_attorney_contact, power_of_attorney_params)
        will_poa_id = CardDocument.find_by(card_id: @power_of_attorney_contact.id, object_type: 'PowerOfAttorneyContact').id
        ShareInheritanceService.update_document_shares(resource_owner, @power_of_attorney_contact.share_with_contact_ids,
                                                       @previous_shared_with, Rails.application.config.x.WillsPoaCategory, nil, nil, nil, will_poa_id)
        @path = success_path(power_of_attorney_path(@power_of_attorney_contact), power_of_attorney_path(@power_of_attorney_contact, resource_owner))
        format.html { redirect_to @path, flash: { success: 'Power of Attorney successfully update.' } }
        format.json { render :show, status: :created, location: @insurance_card }
      else
        error_path(:edit)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout] }
        format.json { render json: @insurance_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /power_of_attorneys/1
  # DELETE /power_of_attorneys/1.json
  def destroy
    authorize @power_of_attorney
    @power_of_attorney.destroy
    respond_to do |format|
      format.html { redirect_to back_path || wills_powers_of_attorney_path, notice: 'Power of attorney was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def destroy_power_of_attorney_contact
    authorize @power_of_attorney_contact
    @power_of_attorney_contact.destroy
    respond_to do |format|
      format.html { redirect_to wills_powers_of_attorney_path, notice: 'Power of attorney was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def get_powers_of_attorney_details
    render :json => WtlService.get_powers_of_attorney_details(PowerOfAttorney.for_user(resource_owner))
  end

  def details; end

  private
  
  def set_viewable_contacts
    @vault_entries.each do |attorney|
      attorney.share_with_contact_ids |= category_subcategory_shares(attorney, resource_owner).map(&:contact_id)
    end
  end
  
  def set_viewable_contacts_global
    @power_of_attorney_contact.share_with_contact_ids = category_subcategory_shares(@power_of_attorney_contact, resource_owner).map(&:contact_id)
  end
  
  def attorneys
    return PowerOfAttorney.for_user(resource_owner) unless @shared_user
    return @shares.select(&:shareable_type).select { |sh| Object.const_defined?(sh.shareable_type) }.map(&:shareable).select { |resource| resource.is_a? PowerOfAttorney } unless category_shared?
    PowerOfAttorney.for_user(@shared_user)
  end
  
  def category_shared?
     @shared_category_names.include? Rails.application.config.x.WtlCategory
  end
  
  def error_path(action)
    @path = ReturnPathService.error_path(resource_owner, current_user, params[:controller], action)
    @shared_user = ReturnPathService.shared_user(@path)
    @shared_category_names_full = ReturnPathService.shared_category_names(@path)
  end
  
    def success_path(common_path, shared_view_path)
      ReturnPathService.success_path(resource_owner, current_user, common_path, shared_view_path)
    end

  def resource_owner 
    if shared_user_params[:shared_user_id].present?
      User.find_by(id: params[:shared_user_id])
    else
      @power_of_attorney_contact.present? ? @power_of_attorney_contact.user : current_user
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
  
  def set_power_of_attorney_contact
    @power_of_attorney_contact = PowerOfAttorneyContact.find(params[:id])
  end
  
  def update_share_params
    if general_view?
      viewable_shares = full_category_shares(Category.fetch(Rails.application.config.x.WillsPoaCategory.downcase), resource_owner).map(&:contact_id).map(&:to_s)
      params[:power_of_attorney_contact]["share_with_contact_ids"] -= viewable_shares
    end
  end
  
  def shared_user_params
    params.permit(:shared_user_id)
  end
  
  def attorneys_shared_with_uniq_param
    power_of_attorney_params.values.map { |x| x["share_with_contact_ids"] }.flatten.uniq.reject(&:blank?)
  end
  
  def power_of_attorney_contact_params
    params.require(:power_of_attorney_contact).permit(:id, :contact_id, share_with_contact_ids: [])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def power_of_attorney_params
    attorneys = params[:power_of_attorney_contact].select { |k, _v| k.starts_with?("vault_entry_") }
    permitted_params = {}
    attorneys.keys.each do |attorney|
      permitted_params[attorney] = [:id, :agent_ids, :notes, :document_id, powers: PowerOfAttorney::POWERS]
    end
    attorneys.values.map { |p| p["powers"] }.each { |p| p.reject! { |_k, v| v.blank? } }
    attorneys.permit(permitted_params)
  end
  
  def success_message(old_attorneys)
    return 'Power of Attorney was successfully created.' unless old_attorneys.any?
    'Power of Attorney was successfully updated.'
  end
  
  def authorize_save(resource)
    authorize_ids = power_of_attorney_params.values.map { |x| x[:id].to_i }
    if authorize_ids.include? resource.id
      authorize resource
    end
  end
  
  def set_previous_shared_with
    @previous_shared_with = @power_of_attorney_contact.share_with_contact_ids
  end
end
