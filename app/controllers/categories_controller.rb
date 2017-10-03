class CategoriesController < AuthenticatedController
  include BackPathHelper
  include CategoriesHelper
  before_action :set_category, only: [:show, :edit, :update, :destroy]
  layout "shared_view", only: [:shared_view_dashboard]
  
  # Breadcrumbs navigation
  before_action :set_previous_crumbs, only: [:share_category]
  before_action :set_share_category_crumbs, only: [:share_category]
  add_breadcrumb "Wills & Powers of Attorney", :wills_powers_of_attorney_path, only: [:wills_powers_of_attorney]
  add_breadcrumb "Trusts & Entities", :trusts_entities_path, only: [:trusts_entities]
  add_breadcrumb "Insurance", :insurance_path, only: [:insurance]
  include BreadcrumbsCacheModule
  include UserTrafficModule
  include TutorialsHelper
  
  def page_name
    case action_name
    when 'wills_powers_of_attorney'
      return "Wills & Powers of Attorney"
    when 'trusts_entities'
      return "Trusts & Entities"
    when 'insurance'
      return "Insurance"
    when 'share_category'
      @category = Category.fetch(params[:id])
      if @category.name.downcase.eql?(Rails.application.config.x.DocumentsCategory.downcase) 
        return "Document Upload Access"
      else
        return "Share Category + #{@category.try(:name)}"
      end
    end
  end
  
  def set_previous_crumbs
    return unless back_path.present?
    @breadcrumbs = BreadcrumbsCacheModule.cache_breadcrumbs_pop(current_user, @shared_user)
  end
  
  def set_share_category_crumbs
    @category = Category.fetch(params[:id])
    breadcrumb_title = 
      if @category.name.downcase.eql? Rails.application.config.x.DocumentsCategory.downcase
        "Upload Document Access"
      else
        "Category Shared With"
      end
    add_breadcrumb breadcrumb_title, share_category_category_path(@category.name.downcase)
  end

  def index
    @categories = policy_scope(Category).all.each { |c| authorize c }
  end

  def shared_view_dashboard; end

  def insurance
    #TODO: fix bug in padding out groups if missing
    @category = Category.fetch(Rails.application.config.x.InsuranceCategory.downcase)
    set_tutorial_in_progress(insurance_empty?)
    @contacts_with_access = current_user.shares.categories.select { |share| share.shareable.eql? @category }.map(&:contact) 

    @groups = Rails.configuration.x.categories[@category.name]["groups"]
    @insurance_vendors = Vendor.for_user(current_user).where(category: @category)
    @insurance_documents = Document.for_user(current_user).where(category: @category.name)
    session[:ret_url] = "/insurance"
  end

  def redirect_path(category)
    case category.name
    when Rails.application.config.x.InsuranceCategory
      insurance_url
    when Rails.application.config.x.TaxCategory
      taxes_url
    when Rails.application.config.x.FinalWishesCategory
      final_wishes_url
    when Rails.application.config.x.FinancialInformationCategory
      financial_information_url
    when Rails.application.config.x.WillsPoaCategory
      wills_powers_of_attorney_url
    when Rails.application.config.x.TrustsEntitiesCategory
      trusts_entities_url
    when Rails.application.config.x.DocumentsCategory
      documents_url
    when Rails.application.config.x.OnlineAccountCategory
      online_accounts_path
    else
      root_url
    end
  end

  def share
    remove_document_shares
    remove_subcategory_shares
    sc = ShareableCategory.new(
      current_user,
      params[:id],
      shareable_category_params[:share_with_contact_ids]).execute

    check_tutorial_params([]) and return
    redirect_to redirect_path(sc.category)
  end
  
  def share_category
    contact_service = ContactService.new(:user => current_user)
    @contacts_shareable = contact_service.contacts_shareable
    @category = Category.fetch(params[:id])

    @contacts_with_access = current_user.shares.categories.select { |share| share.shareable.eql? @category }.map(&:contact) 
    @shareable_category = ShareableCategory.new(current_user,
                                                @category.id, 
                                                @contacts_with_access.map(&:id))
  end
  
  def wills_powers_of_attorney
    @category = Category.fetch(Rails.application.config.x.WillsPoaCategory.downcase)
    set_tutorial_in_progress(wills_poa_empty?)

    @power_of_attorney_contacts = PowerOfAttorneyContact.for_user(current_user)
    @contacts_with_access = current_user.shares.categories.select { |share| share.shareable.eql? @category }.map(&:contact) 
    @wills = Will.for_user(current_user)
    @wtl_documents = Document.for_user(current_user).where(category: Rails.application.config.x.WillsPoaCategory)

    session[:ret_url] = "/wills_powers_of_attorney"
  end
  
  def trusts_entities
    @category = Category.fetch(Rails.application.config.x.TrustsEntitiesCategory.downcase)
    set_tutorial_in_progress(trusts_entities_empty?)
    @contacts_with_access = current_user.shares.categories.select { |share| share.shareable.eql? @category }.map(&:contact) 
    
    @trusts = Trust.for_user(current_user)
    @entities = Entity.for_user(current_user)
    @documents = Document.for_user(current_user).where(category: Rails.application.config.x.TrustsEntitiesCategory)
    session[:ret_url] = "/trusts_entities"
  end

  def destroy_share_category
    category = Category.fetch(params[:id])
    contact = Contact.find(params[:contact_id])

    shares = current_user.shares.for_category_and_contact(category, contact)
    return unless shares.present?
    shares.each { |share| share.destroy }
  
    redirect_to share_category_category_path
  end

  def details_account
    @category = params[:category]
    group_for_new_account = params[:group]
    groups = Rails.configuration.x.categories[@category]["groups"]
    @group = groups.detect { |group| group["value"] == group_for_new_account }
    @group_documents = DocumentService.new(:category => @category).get_group_documents(current_user, @group["label"])
    session[:ret_url] = details_account_category_path(:category => @category, :group => group_for_new_account, :name => params[:name], :return => params[:return])
  end

  def new_account
    @category = params[:category]
    group_for_new_account = params[:group]
    groups = Rails.configuration.x.categories[@category]["groups"]
    @group = groups.detect { |group| group["value"] == group_for_new_account }
  end

  def show; end

  def new
    @category = Category.new

    authorize @category
  end

  def edit; end

  def create
    @category = Category.new(category_params)

    authorize @category

    respond_to do |format|
      if @category.save
        format.html { redirect_to @category, notice: 'category was successfully created.' }
        format.json { render :show, status: :created, location: @category }
      else
        format.html { render :new }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @category

    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to @category, notice: 'category was successfully updated.' }
        format.json { render :show, status: :ok, location: @category }
      else
        format.html { render :edit }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @category

    @category.destroy
    respond_to do |format|
      format.html { redirect_to categories_url, notice: 'category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  
  def remove_document_shares
    ShareInheritanceService.remove_document_shares(current_user, params[:id].to_i, shareable_category_params)
  end
  
  def remove_subcategory_shares
    ShareInheritanceService.remove_subcategory_shares(current_user, params[:id].to_i, shareable_category_params)
  end

  def set_category
    @category = Category.find(params[:id])
  end

  def shareable_category_params
    params.require(:shareable_category).permit! #(:id, :share_with_contact_ids)
  end
  
  def category_params
    params.require(:category).permit(:name, :description)
  end

  def get_not_assigned_documents(vault_documents)
    Document.for_user(current_user).where(category: @category.name)
            .where.not(id: vault_documents.compact.map(&:id))
  end
  
  # Tutorial workflow integrated
  
  def set_tutorial_resources
    @category_dropdown_options, @card_names, @cards = TutorialService.set_documents_information(@category.name, current_user)
    @contacts = Contact.for_user(current_user).reject { |c| c.emailaddress == current_user.email } 
    @contact = Contact.new(user: current_user)
    case @category.name
      when Rails.application.config.x.WillsPoaCategory
        set_will_tutorial_resources
      when Rails.application.config.x.TrustsEntitiesCategory
        set_trust_tutorial_resources
      when Rails.application.config.x.InsuranceCategory
        set_insurance_tutorial_resources
    end
  end
  
  def set_will_tutorial_resources
    @digital_wills = Document.for_user(current_user).where(category: Rails.application.config.x.WillsPoaCategory)
    @estate_planning_attorneys = Contact.for_user(current_user).where(relationship: 'Attorney', contact_type: 'Advisor')
  end
  
  def set_trust_tutorial_resources
    @trust_planning_attorneys = Contact.for_user(current_user).where(relationship: 'Attorney', contact_type: 'Advisor')
  end
  
  def set_insurance_tutorial_resources
    @insurance_brokers = Contact.for_user(current_user).where(relationship: 'Insurance Agent / Broker', contact_type: 'Advisor')
    @insurance_policies = Document.for_user(current_user).where(category: Rails.application.config.x.InsuranceCategory)
  end
end
