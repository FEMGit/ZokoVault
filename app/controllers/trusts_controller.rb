class TrustsController < AuthenticatedController
  include SharedViewModule
  include SharedViewHelper
  include BackPathHelper
  include TutorialsHelper
  include SanitizeModule
  before_action :set_trust, only: [:show, :edit, :destroy]
  before_action :set_documents, only: [:show]
  before_action :set_contacts, only: [:new, :create, :edit, :update, :new]
  before_action :set_previous_shared_with, only: [:create, :update]

  # General Breadcrumbs
  before_action :set_index_breadcrumbs, :only => %w(new edit show)
  before_action :set_details_crumbs, only: [:edit, :show]
  before_action :set_new_crumbs, only: [:new]
  before_action :set_edit_crumbs, only: [:edit]
  include BreadcrumbsCacheModule
  include UserTrafficModule
  include CancelPathErrorUpdateModule
  
  def set_index_breadcrumbs
    add_breadcrumb "Trusts & Entities", trusts_entities_path if general_view?
    add_breadcrumb "Trusts & Entities", shared_view_trusts_entities_path(@shared_user) if shared_view?
  end

  def set_new_crumbs
    add_breadcrumb "Trusts - Setup", new_trust_path(@shared_user)
  end

  def set_details_crumbs
    add_breadcrumb "#{@trust.name}", trust_path(@trust, @shared_user)
  end

  def set_edit_crumbs
    add_breadcrumb "Trusts - Setup", edit_trust_path(@trust, @shared_user)
  end

  def page_name
    trust = CardDocument.trust(params[:id])
    case action_name
      when 'show'
        return "Trust - #{trust.name} - Details"
      when 'new'
        return "Trust - Setup"
      when 'edit'
        return "Trust - #{trust.name} - Edit"
    end
  end

  def show
    authorize @trust
    session[:ret_url] = trust_path(@trust, @shared_user)
  end

  def new
    @vault_entry = TrustBuilder.new(type: 'trust').build
    @vault_entry.user = resource_owner
    @vault_entry.vault_entry_contacts.build

    @vault_entries = Array.wrap(@vault_entry)
    @vault_entries.each { |x| authorize x }
    set_viewable_contacts
    return if @vault_entries.present?

    @vault_entries << @vault_entry
    @vault_entries.each { |x| authorize x }
  end

  def edit
    authorize @trust
    @vault_entry = @trust
    @vault_entries = Array.wrap(@vault_entry)
    set_viewable_contacts
  end

  def create
    check_tutorial_params(params[:vault_entry_0][:name]) && return
    save_or_update_trust(:new)
  end
  
  def update_all
    TutorialService.update_tutorial_without_dropdown(update_all_params, Trust, resource_owner)
    render :nothing => true
  end

  def update
    save_or_update_trust(:edit)
  end

  def save_or_update_trust(action)
    new_trusts = WtlService.get_new_records(update_share_params)
    old_trusts = WtlService.get_old_records(update_share_params)
    @vault_entries = []
    trusts = new_trusts + old_trusts
    respond_to do |format|
      if trusts.present?
        begin
          update_trusts(new_trusts, old_trusts)
          
          if tutorial_params[:tutorial_name]
            tutorial_redirection(format, @new_vault_entries.as_json, success_message(old_trusts))
          else
            format.html { redirect_to success_path, flash: { success: success_message(old_trusts) } }
            format.json { render :show, status: :created, location: @trust }
          end
        rescue
          tutorial_error_handle("Fill in Trust Name field to continue") && return
          @vault_entry = Trust.new
          @old_params.try(:each) { |trust| @vault_entries << trust }
          @new_params.try(:each) { |trust| @vault_entries << trust }
          error_path(action)
          format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout], locals: @path[:locals] }
          format.json { render json: @errors, status: :unprocessable_entity }
          set_error_breadcrumbs
        end
      else
        tutorial_error_handle("Fill in Trust Name field to continue") && return
        error_path(action)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout], locals: @path[:locals] }
        format.json { render json: @errors, status: :unprocessable_entity }
        set_error_breadcrumbs
      end
    end
  end

  # DELETE /trusts/1
  # DELETE /trusts/1.json
  def destroy
    authorize @trust
    @trust.destroy
    respond_to do |format|
      format.html { redirect_to trusts_entities_path, notice: 'Trust was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_error_breadcrumbs
    breadcrumbs.clear
    set_trust if @path[:action].eql? :edit
    add_breadcrumb "Trusts & Entities", :trusts_entities_path if general_view?
    add_breadcrumb "Trusts & Entities", shared_view_trusts_entities_path(shared_user_id: @shared_user.id) if shared_view?
    set_new_crumbs && return if @path[:action].eql? :new
    if @path[:action].eql? :edit
      set_details_crumbs
      set_edit_crumbs
    end
  end

  def set_documents
    @category = Rails.application.config.x.TrustsEntityCategory
    @group_documents = Document.for_user(resource_owner).where(:category => @trust.category.name, :card_document_id => CardDocument.trust(@trust.id).try(:id))
  end

  def set_viewable_contacts
    @vault_entries.each do |trust|
      trust.share_with_contact_ids |= category_subcategory_shares(trust, resource_owner).map(&:contact_id)
    end
  end

  def error_path(action)
    @path = ReturnPathService.error_path(resource_owner, current_user, params[:controller], action)
    @shared_user = ReturnPathService.shared_user(@path)
    @shared_category_names_full = ReturnPathService.shared_category_names(@path)
  end

  def success_path
    ReturnPathService.success_path(resource_owner, current_user, trust_path((@new_vault_entries || @old_vault_entries)),
      trust_path((@new_vault_entries || @old_vault_entries), resource_owner))
  end

  def resource_owner
    if shared_user_params[:shared_user_id].present?
      User.find_by(id: params[:shared_user_id])
    else
      @trust.present? ? @trust.user : current_user
    end
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

  def update_share_params
    viewable_shares = full_category_shares(Category.fetch(Rails.application.config.x.TrustsEntitiesCategory.downcase), resource_owner).map(&:contact_id).map(&:to_s)
    trust_params.each do |k, v|
      if v["share_with_contact_ids"].present?
        v["share_with_contact_ids"] -= viewable_shares
      end
    end
  end
  
  def tutorial_params
    params.permit(:tutorial_name)
  end

  def shared_user_params
    params.permit(:shared_user_id)
  end

  def trust_shared_with_uinq_param
    trust_params.values.map { |x| x["share_with_contact_ids"] }.flatten.uniq.reject(&:blank?)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def trust_params
    trusts = params.select { |k, _v| k.starts_with?("vault_entry_") }
    permitted_params = {}
    trusts.keys.each do |trust|
      permitted_params[trust] = [:id, :name, :notes, :document_id, agent_ids: [], trustee_ids: [], successor_trustee_ids: [], share_ids: [],
                                 share_with_contact_ids: []]
    end
    trusts.permit(permitted_params)
  end

  def success_message(old_trusts)
    return 'Trust was successfully created.' unless old_trusts.any?
    'Trust was successfully updated.'
  end

  def update_trusts(new_trusts, old_trusts)
    @errors = []
    @new_params = []
    @old_params = []
    old_trusts.each do |old_trust|
      @old_vault_entries = TrustBuilder.new(old_trust.merge(user_id: resource_owner.id).except(:trustee_ids,
                                                                                               :successor_trustee_ids,
                                                                                               :agent_ids)).build
      WtlService.update_shares(@old_vault_entries.id, old_trust[:share_with_contact_ids], resource_owner.id, Trust)
      authorize_save(@old_vault_entries)
      @old_params << @old_vault_entries
      unless @old_vault_entries.save
        @errors << { id: old_trust[:id], error: @old_vault_entries.errors }
      end
      WtlService.update_trustees(@old_vault_entries, old_trust[:trustee_ids],
        old_trust[:successor_trustee_ids], old_trust[:agent_ids])
    end
    new_trusts.each do |new_trust_params|
      @new_vault_entries = TrustBuilder.new(new_trust_params.merge(user_id: resource_owner.id).except(:trustee_ids,
                                                                                                      :successor_trustee_ids,
                                                                                                      :agent_ids)).build
      if !@new_vault_entries.save
        @new_params << Trust.new(new_trust_params)
        @errors << { id: "", error: @new_vault_entries.errors }
      else
        @new_params << @new_vault_entries
      end
      WtlService.update_shares(@new_vault_entries.id, new_trust_params[:share_with_contact_ids], resource_owner.id, Trust)
      WtlService.update_trustees(@new_vault_entries, new_trust_params[:trustee_ids],
                                 new_trust_params[:successor_trustee_ids], new_trust_params[:agent_ids])
    end
    will_poa_id = CardDocument.find_by(card_id: (@new_vault_entries || @old_vault_entries).id, object_type: 'Trust').id
    ShareInheritanceService.update_document_shares(resource_owner, trust_shared_with_uinq_param, @previous_shared_with,
                                                   Rails.application.config.x.TrustsEntitiesCategory, nil, nil, nil, will_poa_id)
    raise "error saving new trust" if @errors.any?
  end

  def authorize_save(resource)
    authorize_ids = trust_params.values.map { |x| x[:id].to_i }
    if authorize_ids.include? resource.id
      authorize resource
    end
  end

  def set_previous_shared_with
    old_trusts = WtlService.get_old_records(trust_params)
    old_trust_ids = old_trusts.map { |x| x["id"] }.flatten.uniq.reject(&:blank?)
    @previous_shared_with = Trust.find(old_trust_ids).map(&:share_with_contact_ids).flatten.uniq
  end
end
