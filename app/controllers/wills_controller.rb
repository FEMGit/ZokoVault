class WillsController < AuthenticatedController
  include SharedViewModule
  include SharedViewHelper
  include BackPathHelper
  include SanitizeModule
  before_action :set_will, only: [:show, :edit, :destroy]
  before_action :set_documents, only: [:show]
  before_action :set_contacts, only: [:new, :create, :edit, :update]
  before_action :set_previous_shared_with, only: [:create, :update]
  before_action :update_share_params, only: [:create, :update]

  before_action :set_index_breadcrumbs, :only => %w(new edit show)
  before_action :set_details_crumbs, only: [:edit, :show]
  before_action :set_new_crumbs, only: [:new]
  before_action :set_edit_crumbs, only: [:edit]
  include BreadcrumbsCacheModule
  include BreadcrumbsErrorModule
  include UserTrafficModule
  include PageTitle
  include CancelPathErrorUpdateModule
  
  def set_index_breadcrumbs
    add_breadcrumb "Wills & Powers of Attorney", wills_powers_of_attorney_path if general_view?
    add_breadcrumb "Wills & Powers of Attorney", wills_powers_of_attorney_shared_view_path(@shared_user) if shared_view?
  end

  def set_new_crumbs
    add_breadcrumb "Wills - Setup", new_will_path(@shared_user)
  end

  def set_details_crumbs
    add_breadcrumb "#{@will.title}", will_path(@will, @shared_user)
  end

  def set_edit_crumbs
    add_breadcrumb "Wills - Setup", edit_will_path(@will, @shared_user)
  end

  def page_name
    will = CardDocument.will(params[:id])
    case action_name
      when 'show'
        return "Will - #{will.name} - Details"
      when 'new'
        return "Wills - Setup"
      when 'edit'
        return "Will - #{will.name} - Edit"
    end
  end

  def new
    @vault_entry = WillBuilder.new(type: 'will').build
    @vault_entry.user = resource_owner
    @vault_entry.vault_entry_contacts.build
    @vault_entry.vault_entry_beneficiaries.build

    @vault_entries = Array.wrap(@vault_entry)
    @vault_entries.each { |x| authorize x }
    set_viewable_contacts
    return unless @vault_entries.empty?

    @vault_entries << @vault_entry
    @vault_entries.each { |x| authorize x }
  end

  def edit
    authorize @will

    @vault_entry = @will
    @vault_entries = Array.wrap(@vault_entry)
    set_viewable_contacts
  end

  def show
    authorize @will
    session[:ret_url] = will_path(@will, @shared_user)
  end

  def set_documents
    @category = Rails.application.config.x.WillsPoaCategory
    @group_documents = Document.for_user(resource_owner).where(:category => @will.category.name, :card_document_id => CardDocument.will(@will.id).id)
  end

  def create
    save_or_update_will(:new)
  end

  def update
    save_or_update_will(:edit)
  end

   def save_or_update_will(action)
    new_wills = WtlService.get_new_records(update_share_params)
    old_wills = WtlService.get_old_records(update_share_params)
    @vault_entries = []
    respond_to do |format|
      if new_wills.any? || old_wills.any?
        begin
          update_wills(new_wills, old_wills)
          format.html { redirect_to success_path, flash: { success: success_message(old_wills) } }
          format.json { render :show, status: :created, location: @will }
        rescue
          @vault_entry = Will.new
          @old_params.each { |will| @vault_entries << will }
          @new_params.each { |will| @vault_entries << will }
          error_path(action)
          format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout], locals: @path[:locals] }
          format.json { render json: @errors, status: :unprocessable_entity }
        end
      else
        error_path(action)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout], locals: @path[:locals] }
        format.json { render json: @errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wills/1
  # DELETE /wills/1.json
  def destroy
    authorize @will
    @will.destroy
    respond_to do |format|
      format.html { redirect_to wills_powers_of_attorney_path, notice: 'Will was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def set_group
    @group = "Will"
  end

  private

  def set_viewable_contacts
    @vault_entries.each do |will|
      will.share_with_contact_ids |= category_subcategory_shares(will, resource_owner).map(&:contact_id)
    end
  end

  def error_path(action)
    error_path_generate(action) do
      wills_error_breadcrumb_update
      set_viewable_contacts
    end
  end

  def success_path
    ReturnPathService.success_path(resource_owner, current_user, will_path((@new_vault_entries || @old_vault_entries)),
      will_path((@new_vault_entries || @old_vault_entries), resource_owner))
  end

  def resource_owner
    if shared_user_params[:shared_user_id].present?
      User.find_by(id: params[:shared_user_id])
    else
      @will.present? ? @will.user : current_user
    end
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

  def update_share_params
    viewable_shares = full_category_shares(Category.fetch(Rails.application.config.x.WillsPoaCategory.downcase), resource_owner).map(&:contact_id).map(&:to_s)
    will_params.each do |k, v|
      if v["share_with_contact_ids"].present?
        v["share_with_contact_ids"] -= viewable_shares
      end
    end
  end

  def shared_user_params
    params.permit(:shared_user_id)
  end

  def will_shared_with_uniq_param
    will_params.values.map { |x| x["share_with_contact_ids"] }.flatten.uniq.reject(&:blank?).map(&:to_i)
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

  def success_message(old_wills)
    return 'Will was successfully created.' unless old_wills.any?
    'Will was successfully updated.'
  end

  def update_wills(new_wills, old_wills)
    @errors = []
    @new_params = []
    @old_params = []
    old_wills.each do |old_will|
      @old_vault_entries = WillBuilder.new(old_will.merge(user_id: resource_owner.id)).build
      WtlService.update_shares(@old_vault_entries.id, old_will[:share_with_contact_ids], resource_owner.id, Will)
      authorize_save(@old_vault_entries)
      @old_params << @old_vault_entries
      unless @old_vault_entries.save
        @errors << { id: old_will[:id], error: @old_vault_entries.errors }
      end

      WtlService.update_beneficiaries(@old_vault_entries, old_will[:primary_beneficiary_ids],
                                        old_will[:secondary_beneficiary_ids], old_will[:agent_ids])
    end
    new_wills.each do |new_will_params|
      @new_vault_entries = WillBuilder.new(new_will_params.merge(user_id: resource_owner.id).except(:primary_beneficiary_ids, :secondary_beneficiary_ids, :agent_ids)).build
      if !@new_vault_entries.save
        @new_params << Will.new(new_will_params.merge(category: Category.fetch(Rails.application.config.x.WillsPoaCategory.downcase)))
        @errors << { id: "", error: @new_vault_entries.errors }
      else
        @new_params << @new_vault_entries
        WtlService.update_shares(@new_vault_entries.id, new_will_params[:share_with_contact_ids], resource_owner.id, Will)
        WtlService.update_beneficiaries(@new_vault_entries, new_will_params[:primary_beneficiary_ids],
                                        new_will_params[:secondary_beneficiary_ids], new_will_params[:agent_ids])
      end
    end
    will_poa_id = CardDocument.find_by(card_id: (@new_vault_entries || @old_vault_entries).id, object_type: 'Will').id
    ShareInheritanceService.update_document_shares(resource_owner, will_shared_with_uniq_param,
                                                   @previous_shared_with, Rails.application.config.x.WillsPoaCategory, nil, nil, nil, will_poa_id)
    raise "error saving new will" if @errors.any?
  end

  def authorize_save(resource)
    authorize_ids = will_params.values.map { |x| x[:id].to_i }
    if authorize_ids.include? resource.id
      authorize resource
    end
  end

  def set_previous_shared_with
    old_wills = WtlService.get_old_records(will_params)
    old_will_ids = old_wills.map { |x| x["id"] }.flatten.uniq.reject(&:blank?)
    @previous_shared_with = Will.find(old_will_ids).map(&:share_with_contact_ids).flatten.uniq.map(&:to_i)
  end
end
