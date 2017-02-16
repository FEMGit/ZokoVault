class TrustsController < AuthenticatedController
  include SharedViewModule
  include SharedViewHelper
  include BackPathHelper
  before_action :set_trust, :set_document_params, only: [:show, :edit, :update, :destroy]
  before_action :set_contacts, only: [:new, :create, :edit, :update]
  before_action :set_previous_shared_with, only: [:create]
  before_action :set_ret_url
  before_action :set_document_params, only: [:index]
  
  # General Breadcrumbs
  add_breadcrumb "Wills Trusts & Legal", :estate_planning_path, :only => %w(new edit index), if: :general_view?
  add_breadcrumb "Trusts", :trusts_path, :only => %w(edit index new), if: :general_view?
  add_breadcrumb "Trusts - Setup", :new_trust_path, :only => %w(new), if: :general_view?
  # Shared BreadCrumbs
  add_breadcrumb "Wills Trusts & Legal", :shared_view_estate_planning_path, :only => %w(new edit index), if: :shared_view?
  add_breadcrumb "Trusts", :shared_trusts_path, :only => %w(edit index new), if: :shared_view?
  add_breadcrumb "Trusts - Setup", :shared_new_trusts_path, :only => %w(new), if: :shared_view?
  include BreadcrumbsCacheModule
  
  # GET /trusts
  # GET /trusts.json
  def index
    @trusts = trusts
    @trusts.each { |x| authorize x }
    session[:ret_url] = @shared_user.present? ? shared_trusts_path : trusts_path
  end

  # GET /trusts/1
  # GET /trusts/1.json
  def show; end

  # GET /trusts/new
  def new
    @vault_entry = TrustBuilder.new(type: 'trust').build
    @vault_entry.user = resource_owner
    @vault_entry.vault_entry_contacts.build

    @vault_entries = trusts
    @vault_entries.each { |x| authorize x }
    set_viewable_contacts
    return if @vault_entries.present?

    @vault_entries << @vault_entry
    @vault_entries.each { |x| authorize x }
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
    new_trusts = WtlService.get_new_records(update_share_params)
    old_trusts = WtlService.get_old_records(update_share_params)
    @vault_entries = []
    trusts = new_trusts + old_trusts
    respond_to do |format|
      if trusts.present?
        begin
          update_trusts(new_trusts, old_trusts)
          format.html { redirect_to success_path, flash: { success: success_message(old_trusts) } }
          format.json { render :show, status: :created, location: @trust }
        rescue
          @vault_entry = Trust.new
          @old_params.try(:each) { |trust| @vault_entries << trust }
          @new_params.try(:each) { |trust| @vault_entries << trust }
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

  # DELETE /trusts/1
  # DELETE /trusts/1.json
  def destroy
    @trust.destroy
    respond_to do |format|
      format.html { redirect_to back_path || trusts_url, notice: 'Trust was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def set_ret_url
    session[:ret_url] = trusts_path
  end

  private
  
  def set_viewable_contacts
    @vault_entries.each do |trust|
      trust.share_with_contact_ids |= category_subcategory_shares(trust, resource_owner).map(&:contact_id)
    end
  end
  
  def trusts
    return Trust.for_user(resource_owner) unless @shared_user
    return @shares.map(&:shareable).select { |resource| resource.is_a? Trust } unless category_shared?
    Trust.for_user(@shared_user)
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
    ReturnPathService.success_path(resource_owner, current_user, trusts_path, shared_trusts_path(shared_user_id: resource_owner.id))
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
    viewable_shares = full_category_shares(Category.fetch(Rails.application.config.x.WtlCategory.downcase), resource_owner).map(&:contact_id).map(&:to_s)
    trust_params.each do |k, v|
      if v["share_with_contact_ids"].present?
        v["share_with_contact_ids"] -= viewable_shares
      end
    end
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
      permitted_params[trust] = [:id, :name, :agent_ids, :notes, :document_id, trustee_ids: [], successor_trustee_ids: [], share_ids: [],
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
      @old_vault_entries = TrustBuilder.new(old_trust.merge(user_id: resource_owner.id)).build
      authorize_save(@old_vault_entries)
      @old_params << @old_vault_entries
      unless @old_vault_entries.save
        @errors << { id: old_trust[:id], error: @old_vault_entries.errors }
      end
      WtlService.update_shares(@old_vault_entries.id, old_trust[:share_with_contact_ids], resource_owner.id, Trust)
    end
    new_trusts.each do |new_trust_params|
      @new_vault_entries = TrustBuilder.new(new_trust_params.merge(user_id: resource_owner.id)).build
      if !@new_vault_entries.save
        @new_params << Trust.new(new_trust_params)
        @errors << { id: "", error: @new_vault_entries.errors }
      else
        @new_params << @new_vault_entries
      end
      WtlService.update_shares(@new_vault_entries.id, new_trust_params[:share_with_contact_ids], resource_owner.id, Trust)
    end
    ShareInheritanceService.update_document_shares(resource_owner, trust_shared_with_uinq_param, @previous_shared_with,
                                                   Rails.application.config.x.WtlCategory, 'Trust')
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
