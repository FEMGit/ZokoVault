class LifeAndDisabilitiesController < AuthenticatedController
  include SharedViewModule
  include SharedViewHelper
  include BackPathHelper
  before_action :set_life, only: [:show, :edit, :update, :destroy_provider]
  before_action :set_policy, :provider_by_policy, only: [:destroy]
  before_action :set_contacts, only: [:new, :create, :edit, :update]
  before_action :prepare_life_share_params, only: [:create, :update]
  after_action :set_viewable_contacts, only: [:new, :edit]
  
  # Breadcrumbs navigation
  add_breadcrumb "Insurance", :insurance_path, :only => %w(new edit show index), if: :general_view?
  add_breadcrumb "Insurance", :shared_view_insurance_path, :only => %w(new edit show index), if: :shared_view?
  before_action :set_details_crumbs, only: [:edit, :show]
  add_breadcrumb "Life & Disability - Setup", :new_life_path, :only => %w(new), if: :general_view?
  add_breadcrumb "Life & Disability - Setup", :shared_new_life_path, :only => %w(new), if: :shared_view?
  before_action :set_edit_crumbs, only: [:edit]
  include BreadcrumbsCacheModule
  
  def set_details_crumbs
    add_breadcrumb "#{@life_and_disability.name}", life_path(@life_and_disability) if general_view?
    add_breadcrumb "#{@life_and_disability.name}", shared_life_path(@shared_user, @life_and_disability) if shared_view?
  end
  
  def set_edit_crumbs
    add_breadcrumb "Life & Disability - Setup", edit_life_path(@life_and_disability) if general_view?
    add_breadcrumb "Life & Disability - Setup", shared_edit_life_path(@shared_user, @life_and_disability) if shared_view?
  end

  # GET /lives
  # GET /lives.json
  def index
    @life_and_disabilities = life_and_disabilities
    @life_and_disabilities.each { |x| authorize x }
    session[:ret_url] = @shared_user.present? ? shared_lives_path : lives_path
  end

  # GET /lives/1
  # GET /lives/1.json
  def show
    authorize @life_and_disability

    @insurance_card = @life_and_disability
    @group_label = "Life & Disability"
    @group_documents = DocumentService.new(:category => @insurance_card.category).get_insurance_documents(resource_owner, @group_label, params[:id])
  end

  # GET /lives/new
  def new
    @insurance_card = LifeAndDisability.new(user: resource_owner, category: Category.fetch(Rails.configuration.x.InsuranceCategory.downcase))
    @insurance_card.policy.build
    authorize @insurance_card
    set_viewable_contacts
  end

  # GET /lives/1/edit
  def edit
    authorize @life_and_disability

    @insurance_card = @life_and_disability
    @insurance_card.share_with_ids = @life_and_disability.share_ids.collect { |x| Share.find(x).contact_id.to_s }
    set_viewable_contacts
  end

  # POST /lives
  # POST /lives.json
  def create
    @insurance_card = LifeAndDisability.new(life_params.merge(user_id: resource_owner.id, category: Category.fetch(Rails.configuration.x.InsuranceCategory.downcase)))
    authorize @insurance_card
    PolicyService.fill_life_policies(policy_params, @insurance_card)
    respond_to do |format|
      if validate_params && @insurance_card.save
        PolicyService.update_shares(@insurance_card.id, @insurance_card.share_with_ids.map(&:to_i), nil, resource_owner)
        @path = success_path(life_path(@insurance_card), shared_life_path(shared_user_id: resource_owner.id, id: @insurance_card.id))
        format.html { redirect_to @path, flash: { success: 'Insurance successfully created.' } }
        format.json { render :show, status: :created, location: @insurance_card }
      else
        error_path(:new)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout] }
        format.json { render json: @insurance_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lives/1
  # PATCH/PUT /lives/1.json
  def update
    @insurance_card = @life_and_disability
    authorize @insurance_card
    @previous_share_with_ids = @insurance_card.share_with_contact_ids
    PolicyService.fill_life_policies(policy_params, @insurance_card)
    respond_to do |format|
      if validate_params && @insurance_card.update(life_params)
        PolicyService.update_shares(@insurance_card.id, @insurance_card.share_with_ids.map(&:to_i), @previous_share_with_ids, resource_owner)
        @path = success_path(life_path(@insurance_card), shared_life_path(shared_user_id: resource_owner.id, id: @insurance_card.id))
        format.html { redirect_to @path, flash: { success: 'Insurance was successfully updated.' } }
        format.json { render :show, status: :ok, location: @insurance_card }
      else
        error_path(:edit)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout] }
        format.json { render json: @insurance_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lives/1
  # DELETE /lives/1.json
  def destroy
    authorize @life_and_disability

    @policy.destroy
    respond_to do |format|
      format.html { redirect_to back_path || lives_url, notice: 'Insurance policy was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # DELETE /provider/1
  def destroy_provider
    authorize @life_and_disability

    @life_and_disability.destroy
    respond_to do |format|
      format.html { redirect_to insurance_path, notice: 'Insurance was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  
  def validate_params
    policy_params.values.select{ |x| LifeAndDisabilityPolicy::policy_types.exclude? x["policy_type"] }.count.eql? 0
  end
  
  def set_viewable_contacts
    @insurance_card.share_with_ids |= category_subcategory_shares(@insurance_card, resource_owner).map(&:contact_id)
  end
  
  def life_and_disabilities
    return LifeAndDisability.for_user(resource_owner) unless @shared_user
    return @shares.map(&:shareable).select { |resource| resource.is_a? LifeAndDisability } unless @category_shared
    LifeAndDisability.for_user(@shared_user)
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
      @life_and_disability.present? ? @life_and_disability.user : current_user
    end
  end
  
  def provider_by_policy
    @life_and_disability = LifeAndDisability.for_user(current_user).detect { |p| p.policy.any? { |x| x == @policy } }
  end

  def set_life
    @life_and_disability = LifeAndDisability.find(params[:id])
  end

  def set_policy
    @policy = LifeAndDisabilityPolicy.find(params[:id])
  end

  def set_contacts
    contact_service = ContactService.new(:user => resource_owner)
    @contacts = contact_service.contacts
    @contacts_shareable = contact_service.contacts_shareable
  end
  
  def prepare_life_share_params
    return unless life_params[:share_with_ids].present?
    viewable_shares = full_category_shares(Category.fetch(Rails.application.config.x.InsuranceCategory.downcase), resource_owner).map(&:contact_id).map(&:to_s)
    params[:life_and_disability][:share_with_ids] -= viewable_shares
    params[:life_and_disability][:share_with_ids].reject!(&:blank?)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def life_params
    params.require(:life_and_disability).permit(:id, :name, :webaddress, :street_address_1, :city, :state, :zip, :phone, :fax, :contact_id, 
                                                share_with_ids: [])
  end

  def policy_params
    policies = params[:life_and_disability].select { |k, _v| k.starts_with?("policy_") }
    permitted_params = {}
    policies.keys.each do |policy_key|
      permitted_params[policy_key] = [:id, :policy_type, :policy_holder_id, :coverage_amount, :policy_number, :broker_or_primary_contact_id, :notes,
                                      primary_beneficiary_ids: [], secondary_beneficiary_ids: []]
    end
    policies.permit(permitted_params)
  end
end
