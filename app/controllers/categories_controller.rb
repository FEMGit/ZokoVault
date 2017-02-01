class CategoriesController < AuthenticatedController
  before_action :set_category, only: [:show, :edit, :update, :destroy]
  layout "shared_view", only: [:shared_view_dashboard]
  
  # Breadcrumbs navigation
  before_action :set_previous_crumbs, only: [:share_category]
  before_action :set_share_category_crumbs, only: [:share_category]
  add_breadcrumb "Wills Trusts & Legal", :estate_planning_path, only: [:estate_planning]
  add_breadcrumb "Insurance", :insurance_path, only: [:insurance]
  include BreadcrumbsCacheModule
  
  def set_previous_crumbs
    return unless request.referrer.present?
    @breadcrumbs = BreadcrumbsCacheModule.cache_breadcrumbs_pop(@shared_user || current_user)
  end
  
  def set_share_category_crumbs
    @category = Category.fetch(params[:id])
    add_breadcrumb "Category Shared With", share_category_category_path(@category.name.downcase)
  end

  def index
    @categories = policy_scope(Category).all.each { |c| authorize c }
  end

  def shared_view_dashboard; end

  def insurance
    #TODO: fix bug in padding out groups if missing
    @category = Category.fetch(Rails.application.config.x.InsuranceCategory.downcase)
    @contacts_with_access = current_user.shares.categories.select { |share| share.shareable.eql? @category }.map(&:contact) 

    @groups = Rails.configuration.x.categories[@category.name]["groups"]
    @insurance_vendors = Vendor.for_user(current_user).where(category: @category)
    @insurance_documents = Document.for_user(current_user).where(category: @category.name)
    session[:ret_url] = "/insurance"
  end

  def redirect_path(category)
    case category.name
    when 'Insurance'
      insurance_url
    when 'Taxes'
      taxes_url
    when 'Final Wishes'
      final_wishes_url
    when 'Financial Information'
      financial_information_url
    else
      estate_planning_url
    end
  end

  def share
    remove_document_shares
    remove_subcategory_shares
    sc = ShareableCategory.new(
      current_user,
      params[:id],
      shareable_category_params[:share_with_contact_ids]).execute

    redirect_to redirect_path(sc.category)
  end
  
  def share_category
    @contacts = Contact.for_user(current_user).reject { |c| c.emailaddress == current_user.email } 
    @category = Category.fetch(params[:id])

    @contacts_with_access = current_user.shares.categories.select { |share| share.shareable.eql? @category }.map(&:contact) 
    @shareable_category = ShareableCategory.new(current_user,
                                                @category.id, 
                                                @contacts_with_access.map(&:id))
  end

  def estate_planning
    @category = Category.fetch(Rails.application.config.x.WtlCategory.downcase)
    @contacts_with_access = current_user.shares.categories.select { |share| share.shareable.eql? @category }.map(&:contact) 

    @power_of_attorneys = PowerOfAttorney.for_user(current_user)
    @trusts = Trust.for_user(current_user)
    @wills = Will.for_user(current_user)
    @vault_entries = [@power_of_attorneys, @trusts, @wills].flatten
    vault_documents = @vault_entries.map(&:document)
    @wtl_documents = get_not_assigned_documents(vault_documents)
    session[:ret_url] = "/estate_planning"
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
end
