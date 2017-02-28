class WillsController < AuthenticatedController
  include SharedViewModule
  include SharedViewHelper
  include BackPathHelper
  include SanitizeModule
  before_action :set_will, :set_document_params, only: [:destroy]
  before_action :set_contacts, only: [:new, :create]
  before_action :set_previous_shared_with, only: [:create]
  before_action :update_share_params, only: [:create]
  before_action :set_ret_url
  before_action :set_document_params, only: [:index]
  
  # General Breadcrumbs
  add_breadcrumb "Wills Trusts & Legal", :estate_planning_path, :only => %w(new edit index), if: :general_view?
  add_breadcrumb "Wills", :wills_path, :only => %w(edit index new), if: :general_view?
  add_breadcrumb "Wills - Setup", :new_will_path, :only => %w(new), if: :general_view?
  # Shared BreadCrumbs
  add_breadcrumb "Wills Trusts & Legal", :shared_view_estate_planning_path, :only => %w(new edit index), if: :shared_view?
  add_breadcrumb "Wills", :shared_wills_path, :only => %w(edit index new), if: :shared_view?
  add_breadcrumb "Wills - Setup", :shared_new_wills_path, :only => %w(new), if: :shared_view?
  include BreadcrumbsCacheModule
  
  # GET /wills
  # GET /wills.json
  def index
    @wills = wills
    @wills.each { |x| authorize x }
    session[:ret_url] = @shared_user.present? ? shared_wills_path : wills_path
  end

  # GET /wills/new
  def new
    @vault_entry = WillBuilder.new(type: 'will').build
    @vault_entry.user = resource_owner
    @vault_entry.vault_entry_contacts.build
    @vault_entry.vault_entry_beneficiaries.build

    @vault_entries = wills
    @vault_entries.each { |x| authorize x }
    set_viewable_contacts
    return unless @vault_entries.empty?

    @vault_entries << @vault_entry
    @vault_entries.each { |x| authorize x }
  end

  def set_document_params
    @group = "Will"
    @category = Rails.application.config.x.WtlCategory
    @group_documents = DocumentService.new(:category => @category).get_group_documents(resource_owner, @group)
  end

  # POST /wills
  # POST /wills.json
  def create
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
          error_path(:new)
          format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout], locals: @path[:locals] }
          format.json { render json: @errors, status: :unprocessable_entity }
        end
      else
        error_path(:new)
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
      format.html { redirect_to back_path || wills_url, notice: 'Will was successfully destroyed.' }
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
  
  def set_viewable_contacts
    @vault_entries.each do |will|
      will.share_with_contact_ids |= category_subcategory_shares(will, resource_owner).map(&:contact_id)
    end
  end
  
  def wills
    return Will.for_user(resource_owner) unless @shared_user
    return @shares.map(&:shareable).select { |resource| resource.is_a? Will } unless category_shared?
    Will.for_user(@shared_user)
  end
  
  def category_shared?
     @shared_category_names.include? Rails.application.config.x.WtlCategory
  end
  
  def error_path(action)
    @path = ReturnPathService.error_path(resource_owner, current_user, params[:controller], action)
    @shared_user = ReturnPathService.shared_user(@path)
    @shared_category_names_full = ReturnPathService.shared_category_names(@path)
  end
  
  def success_path
    ReturnPathService.success_path(resource_owner, current_user, wills_path, shared_wills_path(shared_user_id: resource_owner.id))
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
    viewable_shares = full_category_shares(Category.fetch(Rails.application.config.x.WtlCategory.downcase), resource_owner).map(&:contact_id).map(&:to_s)
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
      authorize_save(@old_vault_entries)
      @old_params << @old_vault_entries
      unless @old_vault_entries.save
        @errors << { id: old_will[:id], error: @old_vault_entries.errors }
      end
      WtlService.update_shares(@old_vault_entries.id, old_will[:share_with_contact_ids], resource_owner.id, Will)
    end
    new_wills.each do |new_will_params|
      @new_vault_entries = WillBuilder.new(new_will_params.merge(user_id: resource_owner.id)).build
      if !@new_vault_entries.save
        @new_params << Will.new(new_will_params)
        @errors << { id: "", error: @new_vault_entries.errors }
      else
        @new_params << @new_vault_entries
        WtlService.update_shares(@new_vault_entries.id, new_will_params[:share_with_contact_ids], resource_owner.id, Will)
      end
    end
    ShareInheritanceService.update_document_shares(resource_owner, will_shared_with_uniq_param,
                                                   @previous_shared_with, Rails.application.config.x.WtlCategory, 'Will')
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
