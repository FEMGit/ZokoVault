class HealthsController < AuthenticatedController
  include SharedViewModule
  include SharedViewHelper
  before_action :set_health, only: [:show, :edit, :update, :destroy_provider]
  before_action :set_policy, :provider_by_policy, only: [:destroy]
  before_action :set_contacts, only: [:new, :create, :edit, :update]
  before_action :prepare_health_share_params, only: [:create, :update]
  
  # Breadcrumbs navigation
  add_breadcrumb "Insurance", :insurance_path, :only => %w(new edit show index), if: :general_view?
  add_breadcrumb "Insurance", :shared_view_insurance_path, :only => %w(new edit show index), if: :shared_view?
  before_action :set_details_crumbs, only: [:edit, :show]
  add_breadcrumb "Health - Setup", :new_health_path, :only => %w(new), if: :general_view?
  add_breadcrumb "Health - Setup", :shared_new_health_path, :only => %w(new), if: :shared_view?
  before_action :set_edit_crumbs, only: [:edit]
  include BreadcrumbsCacheModule
  
  def set_details_crumbs
    add_breadcrumb "#{@health.name}", health_path(@health) if general_view?
    add_breadcrumb "#{@health.name}", shared_health_path(@shared_user, @health) if shared_view?
  end
  
  def set_edit_crumbs
    add_breadcrumb "Health - Setup", edit_health_path(@health) if general_view?
    add_breadcrumb "Health - Setup", shared_edit_health_path(@shared_user, @health) if shared_view?
  end

  # GET /healths
  # GET /healths.json
  def index
    @healths = healths
    @healths.each { |x| authorize x }
    session[:ret_url] = @shared_user.present? ? shared_healths_path : healths_path
  end

  # GET /healths/1
  # GET /healths/1.json
  def show
    @insurance_card = @health
    @group_label = "Health"
    @group_documents = DocumentService.new(:category => @insurance_card.category).get_insurance_documents(resource_owner, @group_label, params[:id])
    authorize @health
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
    @insurance_card = Health.new(health_params.merge(user_id: resource_owner.id, category: Category.fetch(Rails.application.config.x.InsuranceCategory.downcase)))
    authorize @insurance_card
    PolicyService.fill_health_policies(policy_params, @insurance_card)
    respond_to do |format|
      if @insurance_card.save
        PolicyService.update_shares(@insurance_card.id, @insurance_card.share_with_ids, nil, resource_owner)
        @path = success_path(health_path(@insurance_card), shared_health_path(shared_user_id: resource_owner.id, id: @insurance_card.id))
        format.html { redirect_to @path, flash: { success: 'Insurance successfully created.' } }
        format.json { render :show, status: :created, location: @insurance_card }
      else
        error_path(:new)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout] }
        format.json { render json: @insurance_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /healths/1
  # PATCH/PUT /healths/1.json
  def update
    @insurance_card = @health
    authorize @insurance_card
    @previous_share_with_ids = @insurance_card.share_with_contact_ids
    PolicyService.fill_health_policies(policy_params, @insurance_card)
    respond_to do |format|
      if @insurance_card.update(health_params)
        PolicyService.update_shares(@insurance_card.id, @insurance_card.share_with_ids.map(&:to_i), @previous_share_with_ids, resource_owner)
        @path = success_path(health_path(@insurance_card), shared_health_path(shared_user_id: resource_owner.id, id: @insurance_card.id))
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
      format.html { redirect_to :back || healths_url, notice: 'Insurance policy was successfully destroyed.' }
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
  
  def set_viewable_contacts
    @insurance_card.share_with_ids |= category_subcategory_shares(@insurance_card, resource_owner).map(&:contact_id)
  end
  
  def healths
    return Health.for_user(resource_owner) unless @shared_user
    return @shares.map(&:shareable).select { |resource| resource.is_a? Health } unless @category_shared
    Health.for_user(@shared_user)
  end
  
  def provider_by_policy
    @health = Health.for_user(current_user).detect { |p| p.policy.any? { |x| x == @policy } }
  end

  def error_path(action)
    @path = ReturnPathService.error_path(resource_owner, current_user, params[:controller], action)
    @shared_user = ReturnPathService.shared_user(@path)
    @shared_category_names_full = ReturnPathService.shared_category_names(@path)
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
      permitted_params[policy_key] = [:id, :policy_type, :policy_number, :group_number, :policy_holder_id, :group_id,
                                      :broker_or_primary_contact_id, :notes, insured_member_ids: []]
    end
    policies.permit(permitted_params)
  end
end
