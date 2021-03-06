class FinancialPropertyController < AuthenticatedController
  include SharedViewModule
  include SharedViewHelper
  include TutorialsHelper
  include SanitizeModule
  before_action :set_financial_property, only: [:show, :edit, :update, :destroy]
  before_action :set_provider, only: [:show, :edit, :update, :destroy, :set_documents]
  before_action :initialize_category_and_group, :set_documents, only: [:show]
  before_action :set_contacts, only: [:new, :create, :edit, :update]
  before_action :prepare_share_params, only: [:create, :update]
  include AccountPolicyOwnerModule

  # Breadcrumbs navigation
  before_action :set_index_breadcrumbs, :only => %w(show new edit)
  before_action :set_add_crumbs, only: [:new]
  before_action :set_details_crumbs, only: [:edit, :show]
  before_action :set_edit_crumbs, only: [:edit]
  include BreadcrumbsCacheModule
  include BreadcrumbsErrorModule
  include UserTrafficModule
  include PageTitle
  include CancelPathErrorUpdateModule

  def page_name
    return if tutorial_params_present?
    financial_property = FinancialProperty.for_user(resource_owner).find_by(id: params[:id])
    case action_name
      when 'new'
        return "Financial Property - Setup"
      when 'edit'
        return "Financial Property - #{financial_property.name} - Edit"
      when 'show'
        return "Financial Property - #{financial_property.name} - Details"
    end
  end
  
  def set_index_breadcrumbs
    add_breadcrumb "Financial Information", financial_information_path if general_view?
    add_breadcrumb "Financial Information", financial_information_shared_view_path(@shared_user) if shared_view?
  end

  def set_add_crumbs
    add_breadcrumb "Financial Property - Setup", new_financial_property_path(@shared_user)
  end

  def set_details_crumbs
    add_breadcrumb "#{@financial_property.name}", financial_property_path(@financial_property, @shared_user)
  end

  def set_edit_crumbs
    add_breadcrumb "Financial Property - Setup", edit_financial_property_path(@financial_property, @shared_user)
  end

  def new
    @financial_property = FinancialProperty.new(user: resource_owner,
                                                category: Category.fetch(Rails.application.config.x.FinancialInformationCategory.downcase))
    authorize @financial_property
    set_viewable_contacts
  end

  def show
    authorize @financial_property
    session[:ret_url] = financial_property_url(@financial_property, @shared_user)
  end

  def edit
    authorize @financial_property
    @financial_property.share_with_contact_ids = @property_provider.share_with_contact_ids
    set_viewable_contacts
  end
  
  def create
    check_tutorial_params(property_params[:name]) && return

    @financial_property = FinancialProperty.new(property_params.merge(user_id: resource_owner.id))
    @financial_provider = FinancialProvider.new(user_id: resource_owner.id, name: property_params[:name], provider_type: provider_type)
    @financial_provider.properties << @financial_property
    authorize @financial_property

    respond_to do |format|
      if validate_params && @financial_provider.save
        FinancialInformationService.update_shares(@financial_provider, @financial_property.share_with_contact_ids, nil, resource_owner, @financial_property)
        FinancialInformationService.update_property_owners(@financial_property, property_owner_params)
        @path = success_path(financial_property_url(@financial_property), financial_property_url(@financial_property, shared_user_id: resource_owner.id))

        if params[:tutorial_name]
          tutorial_redirection(format, @financial_property.as_json)
        else
          format.json { render :show, status: :created, location: @financial_property }
          format.html { redirect_to @path, flash: { success: 'Property was successfully created.' } }
        end
      else
        tutorial_error_handle("Fill in Property Name field to continue") && return
        error_path(:new)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout] }
        format.json { render json: @financial_provider.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update_all
    TutorialService.update_tutorial_without_dropdown(update_all_params, FinancialProperty, resource_owner)
    render :nothing => true
  end

  def update
    authorize @financial_property
    @previous_share_with = @property_provider.share_with_contact_ids
    params_valid = validate_params
    respond_to do |format|
      if params_valid && @financial_property.update(property_params.merge(user_id: resource_owner.id))
        @property_provider.update(name: property_params[:name], provider_type: provider_type)
        FinancialInformationService.update_shares(@property_provider, @financial_property.share_with_contact_ids,
                                                  @previous_share_with, resource_owner, @financial_property)
        FinancialInformationService.update_property_owners(@financial_property, property_owner_params)
        @path = success_path(financial_property_url(@financial_property), financial_property_url(@financial_property, shared_user_id: resource_owner.id))
        format.html { redirect_to @path, flash: { success: 'Property was successfully updated.' } }
        format.json { render :show, status: :created, location: @financial_property }
      else
        error_path(:edit)
        params_valid && @financial_property.update(property_params.merge(user_id: resource_owner.id))
        @financial_property.share_with_contact_ids = (@financial_property.share_with_contact_ids + @previous_share_with).uniq
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout] }
        format.json { render json: @financial_property.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @financial_property
    @financial_property.destroy
    @property_provider.destroy
    respond_to do |format|
      format.html { redirect_to financial_information_path, notice: 'Property was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def provider_type
    FinancialProvider::provider_types["Property"]
  end

  def validate_params
    return false unless (FinancialProperty::property_types.include? property_params[:property_type])
    true
  end

  def set_viewable_contacts
    contacts = category_subcategory_shares(@financial_property, resource_owner)
    return unless contacts.present?
    @financial_property.share_with_contact_ids |= ContactService.filter_contacts(contacts.map(&:contact_id))
  end
  
  def prepare_share_params(error: false)
    return true if current_user != resource_owner
    return unless property_params[:share_with_contact_ids].present?
    viewable_shares = full_category_shares(Category.fetch(Rails.application.config.x.FinancialInformationCategory.downcase), resource_owner).map(&:contact_id).map(&:to_s)
    params[:financial_property][:share_with_contact_ids] -= viewable_shares unless error
    params[:financial_property][:share_with_contact_ids].reject!(&:blank?)
  end

  def shared_user_params
    params.permit(:shared_user_id)
  end

  def resource_owner
    if shared_user_params[:shared_user_id].present?
      User.find_by(id: params[:shared_user_id])
    else
      @property_provider.present? ? @property_provider.user : current_user
    end
  end

  def error_path(action)
    error_path_generate(action) do
      set_account_owners
      financial_property_error_breadcrumb_update
      prepare_share_params(error: true)
      set_viewable_contacts
    end
  end

  def success_path(common_path, shared_view_path)
    ReturnPathService.success_path(resource_owner, current_user, common_path, shared_view_path)
  end

  def set_provider
    set_financial_property
    @property_provider = FinancialProvider.for_user(resource_owner).find(@financial_property.empty_provider_id)
  end

  def set_financial_property
    @financial_property = FinancialProperty.for_user(resource_owner).find(params[:id])
  end

  def set_documents
    @documents = Document.for_user(resource_owner).where(category: @category, financial_information_id: @property_provider.id)
  end

  def initialize_category_and_group
    @category = Rails.application.config.x.FinancialInformationCategory
    @group = "Property"
  end

  def property_params
    params.require(:financial_property).permit(:id, :name, :property_type, :notes, :value, :city, :state, :zip, :address, :primary_contact_id, :category_id,
                                               share_with_contact_ids: [])
  end

  def property_owner_params
    params.require(:financial_property).permit(property_owner_ids: [])
  end

  def set_contacts
    contact_service = ContactService.new(:user => resource_owner)
    @contacts = contact_service.contacts
    @contacts_shareable = contact_service.contacts_shareable
  end
end
