class PropertyAndCasualtiesController < AuthenticatedController
  include SharedViewModule
  include SharedViewHelper
  include BackPathHelper
  include TutorialsHelper
  include SanitizeModule
  before_action :set_property_and_casualty, only: [:show, :edit, :update, :destroy_provider]
  before_action :set_policy, :provider_by_policy, only: [:destroy]
  before_action :set_contacts, only: [:new, :create, :edit, :update]
  before_action :prepare_property_share_params, only: [:create, :update]
  include AccountPolicyOwnerModule

  # Breadcrumbs navigation
  before_action :set_index_breadcrumbs, :only => %w(new edit show index)
  before_action :set_details_crumbs, only: [:edit, :show]
  before_action :set_new_crumbs, only: [:new]
  before_action :set_edit_crumbs, only: [:edit]
  include BreadcrumbsCacheModule
  include BreadcrumbsErrorModule
  include UserTrafficModule
  include CancelPathErrorUpdateModule

  def page_name
    vendor = Vendor.for_user(resource_owner).find_by(id: params[:id])
    case action_name
      when 'show'
        return "#{vendor.type.underscore.humanize} - #{vendor.name} - Details"
      when 'new'
        return "#{controller_name.humanize} - Setup"
      when 'edit'
        return "#{vendor.type.underscore.humanize} - #{vendor.name} - Edit"
    end
  end
  
  def set_index_breadcrumbs
    add_breadcrumb "Insurance", insurance_path if general_view?
    add_breadcrumb "Insurance", insurance_shared_view_path(@shared_user) if shared_view?
  end

  def set_new_crumbs
    add_breadcrumb "Property & Casualty - Setup", :new_property_path if general_view?
    add_breadcrumb "Property & Casualty - Setup", new_property_and_casualty_shared_view_path(@shared_user) if shared_view?
  end

  def set_details_crumbs
    add_breadcrumb "#{@property_and_casualty.name}", property_path(@property_and_casualty) if general_view?
    add_breadcrumb "#{@property_and_casualty.name}", property_and_casualty_shared_view_path(@shared_user, @property_and_casualty) if shared_view?
  end

  def set_edit_crumbs
    add_breadcrumb "Property & Casualty - Setup", edit_property_path(@property_and_casualty) if general_view?
    add_breadcrumb "Property & Casualty - Setup", edit_property_and_casualty_shared_view_path(@shared_user, @property_and_casualty) if shared_view?
  end

  # GET /properties/1
  # GET /properties/1.json
  def show
    authorize @property_and_casualty
    @insurance_card = @property_and_casualty
    @group_label = "Property & Casualty"
    @group_documents = DocumentService.new(:category => @insurance_card.category).get_insurance_documents(resource_owner, @group_label, params[:id])
    session[:ret_url] = general_view? ? property_path(@property_and_casualty) : property_and_casualty_shared_view_path(@shared_user, @property_and_casualty)
  end

  # GET /properties/new
  def new
    initialize_insurance_card
    authorize @insurance_card

    @errors = @insurance_card.errors
    set_viewable_contacts
  end

  def initialize_insurance_card
    @insurance_card = PropertyAndCasualty.new(user: resource_owner, category: Category.fetch(Rails.application.config.x.InsuranceCategory.downcase))
    @insurance_card.policy.build
  end

  # GET /properties/1/edit
  def edit
    @insurance_card = @property_and_casualty
    @insurance_card.share_with_ids = @property_and_casualty.share_ids.collect { |x| Share.find(x).contact_id.to_s }

    authorize @property_and_casualty
    set_viewable_contacts
  end

  # POST /properties
  # POST /properties.json
  def create
    check_tutorial_params(property_and_casualty_params[:name]) and return
    
    @insurance_card = PropertyAndCasualty.new(property_and_casualty_params.merge(user_id: resource_owner.id, category: Category.fetch(Rails.application.config.x.InsuranceCategory.downcase)))
    authorize @insurance_card
    PolicyService.fill_property_and_casualty_policies(policy_params, @insurance_card)
    respond_to do |format|
      if validate_params && @insurance_card.save
        PolicyService.update_shares(@insurance_card.id, @insurance_card.share_with_ids, nil, resource_owner)
        PolicyService.update_properties(@insurance_card, property_params)
        @path = success_path(property_path(@insurance_card), property_and_casualty_shared_view_path(shared_user_id: resource_owner.id, id: @insurance_card.id))
        
        # If comes from Tutorials workflow, redirect to next step
        if params[:tutorial_name]
          tutorial_redirection(format, @insurance_card.as_json)
        else
          format.html { redirect_to @path, flash: { success: 'Insurance successfully created.' } }
          format.json { render :show, status: :created, location: @insurance_card }
        end
      else
        # If comes from Tutorials workflow, redirect to same Tutorial step
        tutorial_error_handle("Fill in Insurance Provider Name field to continue") && return
        error_path(:new)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout] }
        format.json { render json: @insurance_card.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_all
    TutorialService.update_tutorial_without_dropdown(update_all_params, Vendor, resource_owner)
    render :nothing => true
  end
  
  # PATCH/PUT /properties/1
  # PATCH/PUT /properties/1.json
  def update
    @insurance_card = @property_and_casualty
    authorize @insurance_card
    @previous_share_with_ids = @insurance_card.share_with_contact_ids
    PolicyService.fill_property_and_casualty_policies(policy_params, @insurance_card)
    respond_to do |format|
      if validate_params && @insurance_card.update(property_and_casualty_params)
        PolicyService.update_shares(@insurance_card.id, @insurance_card.share_with_ids.map(&:to_i), @previous_share_with_ids, resource_owner)
        PolicyService.update_properties(@insurance_card, property_params)
        @path = success_path(property_path(@insurance_card), property_and_casualty_shared_view_path(shared_user_id: resource_owner.id, id: @insurance_card.id))
        format.html { redirect_to @path, flash: { success: 'Insurance was successfully updated.' } }
        format.json { render :show, status: :ok, location: @insurance_card }
      else
        error_path(:edit)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout] }
        format.json { render json: @insurance_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /properties/1
  # DELETE /properties/1.json
  def destroy
    authorize @property_and_casualty
    @policy.destroy
    respond_to do |format|
      format.html { redirect_to back_path || insurance_path, notice: 'Insurance policy was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # DELETE /provider/1
  def destroy_provider
    authorize @property_and_casualty

    @property_and_casualty.destroy
    respond_to do |format|
      format.html { redirect_to insurance_path, notice: 'Insurance was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  
  def tutorial_params
    params.permit(:tutorial_name)
  end

  def validate_params
    policy_params.values.select{ |x| PropertyAndCasualtyPolicy::policy_types.exclude? x["policy_type"] }.count.eql? 0
  end

  def set_viewable_contacts
    @insurance_card.share_with_ids |= category_subcategory_shares(@insurance_card, resource_owner).map(&:contact_id)
  end

  def property_and_casualties
    return PropertyAndCasualty.for_user(resource_owner) unless @shared_user
    return ShareService.shared_resource(@shares, PropertyAndCasualty) unless @category_shared
    PropertyAndCasualty.for_user(@shared_user)
  end

  def provider_by_policy
    @property_and_casualty = PropertyAndCasualty.for_user(current_user).detect { |p| p.policy.any? { |x| x == @policy } }
  end

  def error_path(action)
    error_path_generate(action) do
      set_contacts
      set_account_owners
      insurance_breadcrumb_update(:property)
      set_viewable_contacts
    end
  end

  def success_path(common_path, shared_view_path)
    ReturnPathService.success_path(resource_owner, current_user, common_path, shared_view_path)
  end

  def shared_user_params
    params.permit(:shared_user_id)
  end

  def resource_owner
    if shared_user_params[:shared_user_id].present?
      User.find_by(id: params[:shared_user_id])
    else
      @property_and_casualty.present? ? @property_and_casualty.user : current_user
    end
  end

  def set_policy
    @policy = PropertyAndCasualtyPolicy.find(params[:id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_property_and_casualty
    @property_and_casualty = PropertyAndCasualty.find(params[:id])
  end

  def set_contacts
    contact_service = ContactService.new(:user => resource_owner)
    @contacts = contact_service.contacts
    @contacts_shareable = contact_service.contacts_shareable
  end

  def prepare_property_share_params
    return unless property_and_casualty_params[:share_with_ids].present?
    viewable_shares = full_category_shares(Category.fetch(Rails.application.config.x.InsuranceCategory.downcase), resource_owner).map(&:contact_id).map(&:to_s)
    params[:property_and_casualty][:share_with_ids] -= viewable_shares
    params[:property_and_casualty][:share_with_ids].reject!(&:blank?)
  end

  def property_and_casualty_params
    params.require(:property_and_casualty).permit(:id, :name, :webaddress, :street_address_1, :city, :state, :zip, :phone, :fax, :contact_id,
                                                  share_with_ids: [])
  end

  def policy_params
    policies = params[:property_and_casualty].select { |k, _v| k.starts_with?("policy_") }
    permitted_params = {}
    policies.keys.each do |policy_key|
      permitted_params[policy_key] = [:id, :policy_type, :insured_property, :policy_holder_id, :coverage_amount, :policy_number,
                                      :broker_or_primary_contact_id, :notes]
    end
    policies.permit(permitted_params)
  end

  def property_params
    policies = params[:property_and_casualty].select { |k, _v| k.starts_with?("policy_") }
    permitted_params = {}
    policies.keys.each do |policy_key|
      permitted_params[policy_key] = [:policy_holder_id]
    end
    policies.permit(permitted_params)
  end
end
