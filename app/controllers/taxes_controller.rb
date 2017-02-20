class TaxesController < AuthenticatedController
  include SharedViewModule
  include SharedViewHelper
  include BackPathHelper
  before_action :set_tax_year, only: [:show, :edit, :update]
  before_action :set_tax, only: [:destroy]
  before_action :set_category, only: [:index, :show]
  before_action :set_year_documents, only: [:show]
  before_action :set_all_documents, only: [:index]
  before_action :set_contacts, only: [:new, :edit]
  before_action :prepare_share_params, only: [:create, :update]
  
  # Breadcrumbs navigation
  add_breadcrumb "Taxes", :taxes_path, if: :general_view?
  add_breadcrumb "Taxes", :shared_view_taxes_path, if: :shared_view?
  before_action :set_details_crumbs, only: [:edit, :show]
  before_action :set_add_edit_crumbs, only: [:edit, :new]
  include BreadcrumbsCacheModule
  
  def set_details_crumbs
    return unless @tax.taxes.any?
    add_breadcrumb "#{@tax.year} Tax Details", show_tax_path(@tax) if general_view?
    add_breadcrumb "#{@tax.year} Tax Details", shared_taxes_path(@shared_user, @tax) if shared_view?
  end
  
  def set_add_edit_crumbs
    if @tax && TaxesService.tax_by_year(@tax.year, resource_owner).present?
      add_breadcrumb "#{@tax.year} Taxes Setup", edit_tax_path(@tax) if general_view?
      add_breadcrumb "#{@tax.year} Taxes Setup", shared_taxes_edit_path(@shared_user, @tax) if shared_view?
    else
      year = params[:year] || Date.today.strftime("%Y").to_i
      add_breadcrumb "#{year} Taxes Setup", new_tax_path(@tax) if general_view?
      add_breadcrumb "#{year} Taxes Setup", shared_new_taxes_path(@shared_user, year) if shared_view?
    end
  end
  
  # GET /taxes
  # GET /taxes.json
  def index
    @category = Category.fetch(Rails.application.config.x.TaxCategory.downcase)
    @contacts_with_access = resource_owner.shares.categories.select { |share| share.shareable.eql? @category }.map(&:contact) 

    @taxes = TaxYearInfo.for_user(resource_owner)
    @taxes.each { |ty| ty.taxes.each { |t| authorize t } }
    session[:ret_url] = @shared_user.present? ? shared_taxes_path : taxes_path
  end

  # GET /taxes/1
  # GET /taxes/1.json
  def show
    @taxes = taxes
    @taxes.each { |t| authorize t }
    session[:ret_url] = @shared_user.present? ? shared_taxes_path(id: @tax.id) : tax_path(@tax)
  end

  # GET /taxes/new
  def new
    year = params[:year] || Date.today.strftime("%Y").to_i
    tax = TaxesService.tax_by_year(year, resource_owner)
    redirect_to edit_tax_path(tax) if tax
    @tax_year = TaxYearInfo.new(user: resource_owner,
                                category: Category.fetch(Rails.application.config.x.TaxCategory.downcase))
    @tax_year[:year] = year
    @tax_year.taxes << Tax.new(user: resource_owner,
                              category: Category.fetch(Rails.application.config.x.TaxCategory.downcase))
    @taxes = @tax_year.taxes
    @taxes.each { |t| authorize t }
    set_viewable_contacts
  end

  # GET /taxes/1/edit
  def edit
    @tax_year = @tax
    @taxes = taxes
    @taxes.each { |t| authorize t }
    set_viewable_contacts
  end

  # POST /taxes
  # POST /taxes.json
  def create
    @tax_year = TaxYearInfo.new(tax_params.merge(user_id: resource_owner.id))
    TaxesService.fill_taxes(tax_form_params, @tax_year, resource_owner.id)
    authorize_save
    respond_to do |format|
      if validate_params && @tax_year.save
        TaxesService.update_shares(@tax_year, nil, resource_owner)
        success_path(tax_path(@tax_year), shared_taxes_path(shared_user_id: resource_owner.id, id: @tax_year.id))
        format.html { redirect_to @path, flash: { success: 'Tax was successfully created.' } }
        format.json { render :show, status: :created, location: @tax_year }
      else
        @taxes = @tax_year.taxes
        @taxes.each { |t| authorize t }
        
        error_path(:new)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout] }
        format.json { render json: @tax_year.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /taxes/1
  # PATCH/PUT /taxes/1.json
  def update
    @tax_year = @tax
    @previous_share_with = @tax_year.taxes.map(&:share_with_contact_ids)
    message = success_message
    TaxesService.fill_taxes(tax_form_params, @tax_year, resource_owner.id)
    authorize_save
    respond_to do |format|
      if validate_params && @tax_year.update(tax_params)
        TaxesService.update_shares(@tax_year, @previous_share_with, resource_owner)
        success_path(tax_path(@tax_year), shared_taxes_path(shared_user_id: resource_owner.id, id: @tax_year.id))
        format.html { redirect_to @path, flash: { success: message } }
        format.json { render :show, status: :ok, location: @tax }
      else
        @taxes = @tax_year.taxes
        @taxes.each { |t| authorize t }
        
        error_path(:edit)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout] }
        format.json { render json: @tax.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /taxes/1
  # DELETE /taxes/1.json
  def destroy
    authorize @tax
    @tax.destroy
    respond_to do |format|
      format.html { redirect_to back_path || taxes_url, notice: 'Tax was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  
  def validate_params
    tax_values = Rails.application.config.x.categories.select { |k, v| k == Rails.application.config.x.TaxCategory }.values
    tax_values.map! {|x| x["groups"]}.flatten!.map! {|x| x["value"]}
    tax_values.include? @tax_year.year.to_s
  end
  
  def set_viewable_contacts
    @taxes.each do |tax|
      tax.share_with_contact_ids |= category_subcategory_shares(tax, resource_owner).map(&:contact_id)
    end
  end
  
  def prepare_share_params
    viewable_shares = full_category_shares(Category.fetch(Rails.application.config.x.TaxCategory.downcase), resource_owner).map(&:contact_id).map(&:to_s)
    tax_form_params.each do |k, v|
      if v["share_with_contact_ids"].present?
        v["share_with_contact_ids"] -= viewable_shares
      end
    end
  end
  
  def authorize_save
    authorize_ids = tax_form_params.values.map { |x| x[:id].to_i }
    @tax_year.taxes.where(:id => authorize_ids).each { |t| authorize t }
  end
  
  def taxes
    return @tax.taxes if @shared_user.nil? || (@shared_category_names.include? 'Taxes')
    contact_ids = Contact.where(emailaddress: current_user.email).map(&:id)
    shared_taxes_ids = Share.where(user: resource_owner, shareable_type: 'Tax', contact_id: contact_ids).map(&:shareable_id)
    @tax.taxes.select { |t| shared_taxes_ids.include? t.id }
  end
  
  def shared_user_params
    params.permit(:shared_user_id)
  end
  
  def error_path(action)
    @path = ReturnPathService.error_path(resource_owner, current_user, params[:controller], action)
    @shared_user = ReturnPathService.shared_user(@path)
    @shared_category_names = ReturnPathService.shared_category_names(@path)
  end
  
  def success_path(common_path, shared_view_path)
    @path = ReturnPathService.success_path(resource_owner, current_user, common_path, shared_view_path)
  end
  
  def resource_owner 
    if shared_user_params[:shared_user_id].present?
      User.find_by(id: params[:shared_user_id])
    else
      @tax.present? ? @tax.user : current_user
    end
  end

  def set_contacts
    contact_service = ContactService.new(:user => resource_owner)
    @contacts = contact_service.contacts
    @contacts_shareable = contact_service.contacts_shareable
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_tax_year
    @tax = TaxYearInfo.for_user(resource_owner).find(params[:id])
  end

  def set_tax
    @tax = Tax.for_user(resource_owner).find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def tax_params
    params.require(:tax_year_info).permit(:id, :year)
  end
  
  def success_message
    return 'Tax was successfully created.' unless @tax.taxes.any?
    'Tax was successfully updated.'
  end

  def set_category
    @category = "Taxes"
  end

  def set_all_documents
    @documents = Document.for_user(resource_owner).where(category: @category)
  end

  def set_year_documents
    @documents = Document.for_user(resource_owner).where(category: @category, group: @tax.year)
  end

  def tax_form_params
    taxes = params[:tax_year_info].select { |k, _v| k.starts_with?("tax") }
    permitted_params = {}
    taxes.keys.each do |tax_key|
      permitted_params[tax_key] = [:id, :tax_preparer_id, :notes, share_with_contact_ids: []]
    end
    taxes.permit(permitted_params)
  end
end
