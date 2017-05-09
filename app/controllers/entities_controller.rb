class EntitiesController < AuthenticatedController
  include SharedViewModule
  include SharedViewHelper
  include BackPathHelper
  include SanitizeModule
  before_action :set_entity, only: [:show, :edit, :update, :destroy]
  before_action :set_documents, only: [:show]
  before_action :set_contacts, only: [:new, :create, :edit, :update]
  before_action :update_share_params, only: [:create, :update]
  before_action :set_previous_shared_with, only: [:update]
  include AccountPolicyOwnerModule

  # General Breadcrumbs
  before_action :set_index_breadcrumbs, :only => %w(new edit index show)
  before_action :set_details_crumbs, only: [:edit, :show]
  before_action :set_new_crumbs, only: [:new]
  before_action :set_edit_crumbs, only: [:edit]
  include BreadcrumbsCacheModule
  include BreadcrumbsErrorModule
  include UserTrafficModule
  include CancelPathErrorUpdateModule
  
  def set_index_breadcrumbs
    add_breadcrumb "Trusts & Entities", trusts_entities_path if general_view?
    add_breadcrumb "Trusts & Entities", shared_view_trusts_entities_path(@shared_user) if shared_view?
  end

  def set_new_crumbs
    add_breadcrumb "Entity - Setup", new_entity_path(@shared_user)
  end

  def set_details_crumbs
    add_breadcrumb "#{@entity.name}", entity_path(@entity, @shared_user)
  end

  def set_edit_crumbs
    add_breadcrumb "Entity - Setup", edit_entity_path(@entity, @shared_user)
  end

  def page_name
    entity = CardDocument.entity(params[:id])
    case action_name
      when 'show'
        "Entity - #{entity.name} - Details"
      when 'new'
        "Entity - Setup"
      when 'edit'
        "Entity - #{entity.name} - Edit"
    end
  end

  def show
    authorize @entity
    session[:ret_url] = entity_path(@entity, @shared_user)
  end

  def edit
    authorize @entity
    set_viewable_contacts
  end

  def new
    @entity = Entity.new(user: resource_owner, category: Category.fetch(Rails.application.config.x.TrustsEntitiesCategory.downcase))
    authorize @entity
    set_viewable_contacts
  end

  def create
    @entity = Entity.new(entity_params.merge(user_id: resource_owner.id, category: Category.fetch(Rails.application.config.x.TrustsEntitiesCategory.downcase)))
    authorize @entity
    respond_to do |format|
      if @entity.save
        WtlService.update_shares(@entity.id, @entity.share_with_contact_ids, resource_owner.id, Entity)
        WtlService.update_entity(@entity, entity_params_multi[:agent_ids], entity_params_multi[:partner_ids])
        format.html { redirect_to success_path, flash: { success: 'Entity successfully created.' } }
        format.json { render :show, status: :created, location: @entity }
      else
        error_path(:new)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout] }
        format.json { render json: @entity.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @entity
    respond_to do |format|
      if @entity.update(entity_params)
        WtlService.update_shares(@entity.id, @entity.share_with_contact_ids, resource_owner.id, Entity)
        WtlService.update_entity(@entity, entity_params_multi[:agent_ids], entity_params_multi[:partner_ids])
        will_poa_id = CardDocument.find_by(card_id: @entity.id, object_type: 'Entity').id
        ShareInheritanceService.update_document_shares(resource_owner, @entity.share_with_contact_ids,
                                                       @previous_shared_with, Rails.application.config.x.TrustsEntitiesCategory, nil, nil, nil, will_poa_id)
        format.html { redirect_to success_path, flash: { success: 'Entity successfully updated.' } }
        format.json { render :show, status: :created, location: @entity }
      else
        error_path(:edit)
        @entity.update(entity_params)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout] }
        format.json { render json: @entity.errors , status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @entity
    @entity.destroy
    respond_to do |format|
      format.html { redirect_to trusts_entities_url, notice: 'Entity was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_documents
    @category = Rails.application.config.x.TrustsEntityCategory
    @group_documents = Document.for_user(resource_owner).where(:category => @entity.category.name, :card_document_id => CardDocument.entity(@entity.id).try(:id))
  end

  def category_shared?
     @shared_category_names.include? Rails.application.config.x.TrustsEntitiesCategory
  end

  def error_path(action)
    set_contacts
    set_account_owners
    @path = ReturnPathService.error_path(resource_owner, current_user, params[:controller], action)
    @shared_user = ReturnPathService.shared_user(@path)
    @shared_category_names_full = ReturnPathService.shared_category_names(@path)
    set_account_owners
    entities_breadcrumb_update
  end

  def success_path
    ReturnPathService.success_path(resource_owner, current_user, entity_path(@entity),
      entity_path(@entity, resource_owner))
  end

  def resource_owner
    if shared_user_params[:shared_user_id].present?
      User.find_by(id: params[:shared_user_id])
    else
      @entity.present? ? @entity.user : current_user
    end
  end

  def set_contacts
    contact_service = ContactService.new(:user => resource_owner)
    @contacts = contact_service.contacts
    @contacts_shareable = contact_service.contacts_shareable
  end

  def set_entity
    @entity = Entity.find(params[:id])
  end

  def set_viewable_contacts
    @entity.share_with_contact_ids = category_subcategory_shares(@entity, resource_owner).map(&:contact_id)
  end

  def update_share_params
    if general_view? && params[:entity]["share_with_contact_ids"].present?
      viewable_shares = full_category_shares(Category.fetch(Rails.application.config.x.TrustsEntitiesCategory.downcase), resource_owner).map(&:contact_id).map(&:to_s)
      params[:entity]["share_with_contact_ids"] -= viewable_shares
    end
  end

  def shared_user_params
    params.permit(:shared_user_id)
  end

  def entity_params
    params[:entity].permit(:name, :notes, share_with_contact_ids: [])
  end

  def entity_params_multi
    params[:entity].permit(agent_ids: [], partner_ids: [])
  end

  def set_previous_shared_with
    @previous_shared_with = @entity.share_with_contact_ids
  end
end
