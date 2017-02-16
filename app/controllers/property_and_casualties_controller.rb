class PropertyAndCasualtiesController < AuthenticatedController
  include SharedViewModule
  include SharedViewHelper
  include BackPathHelper
  before_action :set_property_and_casualty, only: [:show, :edit, :update, :destroy_provider]
  before_action :set_policy, :provider_by_policy, only: [:destroy]
  before_action :set_contacts, only: [:new, :create, :edit, :update]
  before_action :prepare_property_share_params, only: [:create, :update]
  
  # Breadcrumbs navigation
  add_breadcrumb "Insurance", :insurance_path, :only => %w(new edit show index), if: :general_view?
  add_breadcrumb "Insurance", :shared_view_insurance_path, :only => %w(new edit show index), if: :shared_view?
  before_action :set_details_crumbs, only: [:edit, :show]
  add_breadcrumb "Property & Casualty - Setup", :new_property_path, :only => %w(new), if: :general_view?
  add_breadcrumb "Property & Casualty - Setup", :shared_new_property_path, :only => %w(new), if: :shared_view?
  before_action :set_edit_crumbs, only: [:edit]
  include BreadcrumbsCacheModule
  
  def set_details_crumbs
    add_breadcrumb "#{@property_and_casualty.name}", property_path(@property_and_casualty) if general_view?
    add_breadcrumb "#{@property_and_casualty.name}", shared_property_path(@shared_user, @property_and_casualty) if shared_view?
  end
  
  def set_edit_crumbs
    add_breadcrumb "Property & Casualty - Setup", edit_property_path(@property_and_casualty) if general_view?
    add_breadcrumb "Property & Casualty - Setup", shared_edit_property_path(@shared_user, @property_and_casualty) if shared_view?
  end

  # GET /properties
  # GET /properties.json
  def index
    @property_and_casualties = property_and_casualties
    @property_and_casualties.each { |x| authorize x }
    session[:ret_url] = @shared_user.present? ? shared_properties_path : properties_path
  end

  # GET /properties/1
  # GET /properties/1.json
  def show
    @insurance_card = @property_and_casualty
    @group_label = "Property & Casualty"
    @group_documents = DocumentService.new(:category => @insurance_card.category).get_insurance_documents(resource_owner, @group_label, params[:id])
    authorize @property_and_casualty
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
    @insurance_card = PropertyAndCasualty.new(property_and_casualty_params.merge(user_id: resource_owner.id, category: Category.fetch(Rails.application.config.x.InsuranceCategory.downcase)))
    authorize @insurance_card
    PolicyService.fill_property_and_casualty_policies(policy_params, @insurance_card)
    respond_to do |format|
      if validate_params && @insurance_card.save
        PolicyService.update_shares(@insurance_card.id, @insurance_card.share_with_ids, nil, resource_owner)
        @path = success_path(property_path(@insurance_card), shared_property_path(shared_user_id: resource_owner.id, id: @insurance_card.id))
        format.html { redirect_to @path, flash: { success: 'Insurance successfully created.' } }
        format.json { render :show, status: :created, location: @insurance_card }
      else
        error_path(:new)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout] }
        format.json { render json: @insurance_card.errors, status: :unprocessable_entity }
      end
    end
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
        @path = success_path(property_path(@insurance_card), shared_property_path(shared_user_id: resource_owner.id, id: @insurance_card.id))
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
      format.html { redirect_to back_path || properties_url, notice: 'Insurance policy was successfully destroyed.' }
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
  
  def validate_params
    policy_params.values.select{ |x| PropertyAndCasualtyPolicy::policy_types.exclude? x["policy_type"] }.count.eql? 0
  end
  
  def set_viewable_contacts
    @insurance_card.share_with_ids |= category_subcategory_shares(@insurance_card, resource_owner).map(&:contact_id)
  end
  
  def property_and_casualties
    return PropertyAndCasualty.for_user(resource_owner) unless @shared_user
    return @shares.map(&:shareable).select { |resource| resource.is_a? PropertyAndCasualty } unless @category_shared
    PropertyAndCasualty.for_user(@shared_user)
  end

  def provider_by_policy
    @property_and_casualty = PropertyAndCasualty.for_user(current_user).detect { |p| p.policy.any? { |x| x == @policy } }
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
end
