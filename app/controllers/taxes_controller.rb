class TaxesController < AuthenticatedController
  before_action :set_tax_year, only: [:show, :edit, :update]
  before_action :set_tax, only: [:destroy]
  before_action :set_category, only: [:index, :show]
  before_action :set_year_documents, only: [:show]
  before_action :set_all_documents, only: [:index]
  before_action :set_contacts, only: [:new, :edit]
  
  # Breadcrumbs navigation
  add_breadcrumb "Taxes", :taxes_path, :only => %w(show new edit)
  before_action :set_details_crumbs, only: [:edit, :show]
  before_action :set_add_edit_crumbs, only: [:edit, :new]
  
  def set_details_crumbs
    return unless @tax.taxes.any?
    add_breadcrumb "#{@tax.year} Tax Details", show_tax_path(@tax)
  end
  
  def set_add_edit_crumbs
    if @tax && TaxesService.tax_by_year(@tax.year, resource_owner).present?
      add_breadcrumb "#{@tax.year} Taxes Setup", edit_tax_path(@tax)
    else
      year = params[:year] || Date.today.strftime("%Y").to_i
      add_breadcrumb "#{year} Taxes Setup", new_tax_path(@tax)
    end
  end
  
  # GET /taxes
  # GET /taxes.json
  def index
    @category = Category.fetch(Rails.application.config.x.TaxCategory.downcase)
    @contacts_with_access = current_user.shares.categories.select { |share| share.shareable.eql? @category }.map(&:contact) 

    @taxes = TaxYearInfo.for_user(resource_owner)
    session[:ret_url] = taxes_path
  end

  # GET /taxes/1
  # GET /taxes/1.json
  def show
    session[:ret_url] = "#{taxes_path}/#{params[:id]}"
  end

  # GET /taxes/new
  def new
    year = params[:year] || Date.today.strftime("%Y").to_i
    tax = TaxesService.tax_by_year(year, resource_owner)
    redirect_to "#{taxes_path}/#{tax[:id]}/edit" if tax
    @tax_year = TaxYearInfo.new
    @tax_year[:year] = year
    @tax_year.taxes << Tax.new
  end

  # GET /taxes/1/edit
  def edit
    @tax_year = @tax
  end

  # POST /taxes
  # POST /taxes.json
  def create
    @tax_year = TaxYearInfo.new(tax_params.merge(user_id: resource_owner.id))
    TaxesService.fill_taxes(tax_form_params, @tax_year, resource_owner.id)
    respond_to do |format|
      if @tax_year.save
        format.html { redirect_to session[:ret_url] || taxes_path, flash: { success: 'Tax was successfully created.' } }
        format.json { render :show, status: :created, location: @tax_year }
      else
        format.html { render :new }
        format.json { render json: @tax_year.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /taxes/1
  # PATCH/PUT /taxes/1.json
  def update
    @tax_year = @tax
    message = success_message
    TaxesService.fill_taxes(tax_form_params, @tax_year, current_user.id)
    respond_to do |format|
      if @tax_year.update(tax_params)
        TaxesService.update_shares(@tax_year, @tax_year.user_id)
        format.html { redirect_to session[:ret_url] || taxes_path, flash: { success: message } }
        format.json { render :show, status: :ok, location: @tax }
      else
        format.html { render :edit }
        format.json { render json: @tax.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /taxes/1
  # DELETE /taxes/1.json
  def destroy
    @tax.destroy
    respond_to do |format|
      format.html { redirect_to :back || taxes_url, notice: 'Tax was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def resource_owner
    @tax.present? ? @tax.user : current_user
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
