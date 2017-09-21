class HealthsController < AuthenticatedController
  include SharedViewModule
  include SharedViewHelper
  include BackPathHelper
  include TutorialsHelper
  include SanitizeModule
  before_action :set_health, only: [:show, :edit, :update, :destroy_provider]
  before_action :set_policy, :provider_by_policy, only: [:destroy]
  before_action :set_contacts, only: [:new, :create, :edit, :update]
  before_action :prepare_health_share_params, only: [:create, :update]
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
        return "Health - #{vendor.name} - Details"
      when 'new'
        return "Health - Setup"
      when 'edit'
        return "Health - #{vendor.name} - Edit"
    end
  end
  
  def set_index_breadcrumbs
    add_breadcrumb "Insurance", insurance_path if general_view?
    add_breadcrumb "Insurance", insurance_shared_view_path(@shared_user) if shared_view?
  end

  def set_new_crumbs
    add_breadcrumb "Health - Setup", :new_health_path if general_view?
    add_breadcrumb "Health - Setup", new_health_shared_view_path(@shared_user) if shared_view?
  end

  def set_details_crumbs
    add_breadcrumb "#{@health.name}", health_path(@health) if general_view?
    add_breadcrumb "#{@health.name}", health_shared_view_path(@shared_user, @health) if shared_view?
  end

  def set_edit_crumbs
    add_breadcrumb "Health - Setup", edit_health_path(@health) if general_view?
    add_breadcrumb "Health - Setup", edit_health_shared_view_path(@shared_user, @health) if shared_view?
  end

  # GET /healths/1
  # GET /healths/1.json
  def show
    authorize @health
    @insurance_card = @health
    @group_label = "Health"
    @group_documents = DocumentService.new(:category => @insurance_card.category).get_insurance_documents(resource_owner, @group_label, params[:id])
    session[:ret_url] = general_view? ? health_path(@health) : health_shared_view_path(@shared_user, @health)
  end

  # GET /healths/new
  def new
    @insurance_card = Health.new(user: resource_owner, category: Category.fetch(Rails.application.config.x.InsuranceCategory.downcase))
    @insurance_card.policy.build

    authorize @insurance_card
    set_viewable_contacts
  end

  # GET /healths/1/edit
  def edit
    authorize @health

    @insurance_card = @health
    @insurance_card.share_with_ids = @health.share_ids.collect { |x| Share.find(x).contact_id.to_s }
    set_viewable_contacts
  end

  # POST /healths
  # POST /healths.json
  def create
    check_tutorial_params(health_params[:name]) and return
    
    @insurance_card = Health.new(health_params.merge(user_id: resource_owner.id, category: Category.fetch(Rails.application.config.x.InsuranceCategory.downcase)))
    authorize @insurance_card
    PolicyService.fill_health_policies(policy_params, @insurance_card)
    respond_to do |format|
      if validate_params && @insurance_card.save
        PolicyService.update_shares(@insurance_card.id, @insurance_card.share_with_ids, nil, resource_owner)
        PolicyService.update_insured_members(@insurance_card, policy_insured_params)
        @path = success_path(health_path(@insurance_card), health_shared_view_path(shared_user_id: resource_owner.id, id: @insurance_card.id))
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
  
  # PATCH/PUT /healths/1
  # PATCH/PUT /healths/1.json
  def update
    @insurance_card = @health
    authorize @insurance_card
    @previous_share_with_ids = @insurance_card.share_with_contact_ids
    PolicyService.fill_health_policies(policy_params, @insurance_card)
    respond_to do |format|
      if validate_params && @insurance_card.update(health_params)
        PolicyService.update_shares(@insurance_card.id, @insurance_card.share_with_ids.map(&:to_i), @previous_share_with_ids, resource_owner)
        PolicyService.update_insured_members(@insurance_card, policy_insured_params)
        @path = success_path(health_path(@insurance_card), health_shared_view_path(shared_user_id: resource_owner.id, id: @insurance_card.id))
        format.html { redirect_to @path, flash: { success: 'Insurance was successfully updated.' } }
        format.json { render :show, status: :ok, location: @health }
      else
        error_path(:edit)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout] }
        format.json { render json: @health.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /healths/1
  # DELETE /healths/1.json
  def destroy
    authorize @health

    @policy.destroy
    respond_to do |format|
      format.html { redirect_to back_path || healths_url, notice: 'Insurance policy was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # DELETE /provider/1
  def destroy_provider
    authorize @health

    @health.destroy
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
    policy_params.values.select{ |x| HealthPolicy::policy_types.exclude? x["policy_type"] }.count.eql? 0
  end

  def set_viewable_contacts
    @insurance_card.share_with_ids |= category_subcategory_shares(@insurance_card, resource_owner).map(&:contact_id)
  end

  def healths
    return Health.for_user(resource_owner) unless @shared_user
    return ShareService.shared_resource(@shares, Health) unless @category_shared
    Health.for_user(@shared_user)
  end

  def provider_by_policy
    @health = Health.for_user(current_user).detect { |p| p.policy.any? { |x| x == @policy } }
  end

  def error_path(action)
    error_path_generate(action) do
      set_contacts
      set_account_owners
      insurance_breadcrumb_update(:health)
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
      @health.present? ? @health.user : current_user
    end
  end

  def set_policy
    @policy = HealthPolicy.find(params[:id])
  end

  def set_health
    @health = Health.find(params[:id])
  end

  def set_contacts
    contact_service = ContactService.new(:user => resource_owner)
    @contacts = contact_service.contacts
    @contacts_shareable = contact_service.contacts_shareable
  end

  def prepare_health_share_params
    return unless health_params[:share_with_ids].present?
    viewable_shares = full_category_shares(Category.fetch(Rails.application.config.x.InsuranceCategory.downcase), resource_owner).map(&:contact_id).map(&:to_s)
    params[:health][:share_with_ids] -= viewable_shares
    params[:health][:share_with_ids].reject!(&:blank?)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def health_params
    params.require(:health).permit(:id, :name, :webaddress, :street_address_1, :city, :state, :zip, :phone, :fax, :contact_id,
                                   share_with_ids: [])
  end

  def policy_params
    policies = params[:health].select { |k, _v| k.starts_with?("policy_") }
    permitted_params = {}
    policies.keys.each do |policy_key|
      permitted_params[policy_key] = [:id, :policy_type, :policy_number, :group_number, :group_id,
                                      :broker_or_primary_contact_id, :notes]
    end
    policies.permit(permitted_params)
  end

  def policy_insured_params
    policies = params[:health].select { |k, _v| k.starts_with?("policy_") }
    permitted_params = {}
    policies.keys.each do |policy_key|
      permitted_params[policy_key] = [:policy_holder_id, insured_member_ids: []]
    end
    policies.permit(permitted_params)
  end
end
