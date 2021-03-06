class TaxesController < AuthenticatedController
  include SharedViewModule
  include SharedViewHelper
  include BackPathHelper
  include TutorialsHelper
  include SanitizeModule
  include CategoriesHelper
  
  before_action :set_tax_year, only: [:show, :edit, :update]
  before_action :set_tax, only: [:destroy]
  before_action :set_category, only: [:index, :show]
  before_action :set_year_documents, only: [:show]
  before_action :set_all_documents, only: [:index]
  before_action :set_contacts, only: [:new, :edit]
  before_action :prepare_share_params, only: [:create, :update]

  # Breadcrumbs navigation
  before_action :set_index_breadcrumbs
  before_action :set_details_crumbs, only: [:edit, :show]
  before_action :set_add_edit_crumbs, only: [:edit, :new]
  include BreadcrumbsCacheModule
  include UserTrafficModule
  include PageTitle
  include CancelPathErrorUpdateModule
  
  def page_name
    case action_name
      when 'index'
        return "Taxes"
      when 'new'
        return "#{params[:year]} Taxes Setup"
      when 'edit'
        tax_year_info = TaxYearInfo.for_user(resource_owner).find(params[:id])
        return "#{tax_year_info.year} Taxes Edit"
      when 'show'
        tax_year_info = TaxYearInfo.for_user(resource_owner).find(params[:id])
        return "#{tax_year_info.year} Tax Details"
    end
  end
  
  def set_index_breadcrumbs
    add_breadcrumb "Taxes", taxes_path if general_view?
    add_breadcrumb "Taxes", taxes_shared_view_path(@shared_user) if shared_view?
  end

  def set_details_crumbs
    return unless @tax.taxes.any?
    add_breadcrumb "#{@tax.year} Tax Details", tax_path(@tax) if general_view?
    add_breadcrumb "#{@tax.year} Tax Details", tax_shared_view_path(@shared_user, @tax) if shared_view?
  end

  def set_add_edit_crumbs
    if @tax && TaxesService.tax_by_year(@tax.year, resource_owner).present?
      add_breadcrumb "#{@tax.year} Taxes Setup", edit_tax_path(@tax) if general_view?
      add_breadcrumb "#{@tax.year} Taxes Setup", edit_tax_shared_view_path(@shared_user, @tax) if shared_view?
    else
      year = params[:year] || Date.today.strftime("%Y").to_i
      add_breadcrumb "#{year} Taxes Setup", new_tax_path(@tax) if general_view?
      add_breadcrumb "#{year} Taxes Setup", new_tax_shared_view_path(@shared_user, year) if shared_view?
    end
  end

  # GET /taxes
  # GET /taxes.json
  def index
    @category = Category.fetch(Rails.application.config.x.TaxCategory.downcase)
    set_tutorial_in_progress(taxes_empty?)
    @contacts_with_access = resource_owner.shares.categories.select { |share| share.shareable.eql? @category }.map(&:contact)

    @taxes = TaxYearInfo.for_user(resource_owner)
    @taxes.each { |ty| ty.taxes.each { |t| authorize t } }
    session[:ret_url] = @shared_user.present? ? tax_shared_view_path : taxes_path
  end

  # GET /taxes/1
  # GET /taxes/1.json
  def show
    authorize @tax
    @taxes = taxes
    @taxes.each { |t| authorize t }
    session[:ret_url] = @shared_user.present? ? tax_shared_view_path(id: @tax.id) : tax_path(@tax)
  end

  # GET /taxes/new
  def new
    year = params[:year] || Date.today.strftime("%Y").to_i
    tax = TaxesService.tax_by_year(year, resource_owner)
    redirect_to current_user_edit_tax_path(tax) if tax
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
    authorize @tax
    @tax_year = @tax
    @taxes = taxes
    @taxes.each { |t| authorize t }
    set_viewable_contacts
  end
  
  def update_tax_preparers
    tax_accountant_ids = current_user.contacts.where(relationship: 'Accountant', contact_type: 'Advisor').map(&:id)
    parameter_contact_ids = tax_accountant_params.try(:keys).try(:map, &:to_i) || []
    (tax_accountant_ids - parameter_contact_ids).each do |contact_id|
      clean_unchecked_taxes([], contact_id)
    end
      
    tax_accountant_params.try(:each) do |contact_id, accountant_years|
      tax_accountant = resource_owner.contacts.find_by(id: contact_id)
      next unless tax_accountant.present?
      years_for_accountant = accountant_years[:years].keys
      user_tax_years = TaxYearInfo.for_user(resource_owner).map(&:year).uniq

      clean_unchecked_taxes(years_for_accountant, contact_id)
      create_checked_taxes(years_for_accountant, user_tax_years, contact_id)
    end

    respond_to do |format|
      tutorial_redirection(format, nil)
    end
  end

  # POST /taxes
  # POST /taxes.json
  def create
    @tax_year = TaxYearInfo.new(tax_params.merge(user_id: resource_owner.id,
      category: Category.fetch(Rails.application.config.x.TaxCategory.downcase)))
    authorize @tax_year
    TaxesService.fill_taxes(tax_form_params, @tax_year, resource_owner.id)
    authorize_save
    respond_to do |format|
      if validate_params && @tax_year.save
        TaxesService.update_shares(@tax_year, nil, resource_owner)
        success_path(tax_path(@tax_year), tax_shared_view_path(shared_user_id: resource_owner.id, id: @tax_year.id))
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
    authorize @tax
    @tax_year = @tax
    @previous_share_with = @tax_year.taxes.map(&:share_with_contact_ids)
    message = success_message
    TaxesService.fill_taxes(tax_form_params, @tax_year, resource_owner.id)
    authorize_save
    respond_to do |format|
      if validate_params && @tax_year.update(tax_params)
        TaxesService.update_shares(@tax_year, @previous_share_with, resource_owner)
        success_path(tax_path(@tax_year), tax_shared_view_path(shared_user_id: resource_owner.id, id: @tax_year.id))
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
  
  def current_user_edit_tax_path(tax)
    return edit_tax_path(tax) unless @shared_user
    edit_tax_shared_view_path(@shared_user, tax.id)
  end

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
  
  def tax_accountant_params
    return nil unless params[:tax_accountants]
    params.require(:tax_accountants)
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
    contact_ids = Contact.where("emailaddress ILIKE ?", current_user.email).map(&:id)
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
  
  # Tax Accountants Tutorial Update
  def clean_unchecked_taxes(years_for_accountant, contact_id)
    (TaxesLimits::YEARS[:min]..TaxesLimits::YEARS[:max]).each do |year|
      next if years_for_accountant.include? year.to_s
      tax_year_info = TaxYearInfo.for_user(resource_owner).find_by(:year => year.to_i)
      next unless tax_year_info.present?
      tax_year_info.taxes.where(tax_preparer_id: contact_id).destroy_all
    end
  end
  
  def create_checked_taxes(years_for_accountant, user_tax_years, contact_id) 
    years_for_accountant.each do |year|
      if user_tax_years.include? year.to_i
        tax_year_info = TaxYearInfo.for_user(resource_owner).find_by(:year => year.to_i)
        next if tax_year_info.taxes.map(&:tax_preparer_id).include? contact_id.to_i
        tax_year_info.taxes << Tax.create(user: resource_owner, tax_preparer_id: contact_id)
      else
        tax_year_info = TaxYearInfo.new(user: resource_owner, year: year.to_i)
        tax_year_info.taxes << Tax.new(user: resource_owner, tax_preparer_id: contact_id)
        tax_year_info.save
      end
    end
  end
  
  # Tutorial workflow integrated
  def set_tutorial_resources
    @digital_taxes = Document.for_user(resource_owner).where(category: Rails.application.config.x.TaxCategory)
    @tax_accountants = resource_owner.contacts.where(relationship: 'Accountant', contact_type: 'Advisor')
    @category_dropdown_options, @card_names, @cards = TutorialService.set_documents_information(@category.name, resource_owner)
    @contact = Contact.new(user: resource_owner)
  end
end
