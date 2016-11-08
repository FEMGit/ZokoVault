class TaxesController < AuthenticatedController
  before_action :set_tax_year, only: [:show, :edit, :update]
  before_action :set_tax, only: [:destroy]
  before_action :set_category, only: [:index, :show]
  before_action :set_year_documents, only: [:show]
  before_action :set_all_documents, only: [:index]
  before_action :set_contacts, only: [:new, :edit]

  # GET /taxes
  # GET /taxes.json
  def index
    @taxes = TaxYearInfo.for_user(current_user)
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
    tax = TaxesService.tax_by_year(year, current_user)
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
    taxes = tax_form_params
    taxes.keys.each { |x| params[:tax_year_info].delete(x) }
    @tax_year = TaxYearInfo.new(tax_params.merge(user_id: current_user.id))
    TaxesService.fill_taxes(taxes, @tax_year, current_user.id)
    respond_to do |format|
      if @tax_year.save
        format.html { redirect_to session[:ret_url] || taxes_path, notice: 'Tax was successfully created.' }
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
    taxes = tax_form_params
    taxes.keys.each { |x| params[:tax_year_info].delete(x) }
    @tax_year = @tax
    TaxesService.fill_taxes(taxes, @tax_year, current_user.id)
    respond_to do |format|
      if @tax.update(tax_params)
        format.html { redirect_to session[:ret_url] || taxes_path, notice: 'Tax was successfully updated.' }
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

  def set_contacts
    contact_service = ContactService.new(:user => current_user)
    @contacts = contact_service.contacts
    @contacts_shareable = contact_service.contacts_shareable
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_tax_year
    @tax = TaxYearInfo.for_user(current_user).find(params[:id])
  end
  
  def set_tax
    @tax = Tax.for_user(current_user).find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def tax_params
    params.require(:tax_year_info).permit!
  end

  def set_category
    @category = "Taxes"
  end

  def set_all_documents
    @documents = Document.for_user(current_user).where(category: @category)
  end

  def set_year_documents
    @documents = Document.for_user(current_user).where(category: @category, group: @tax.year)
  end

  def tax_form_params
    tax_params.select { |k, _v| k.starts_with?("tax_") }
  end

  def set_category_and_documents
    @category = "Taxes"
    @documents = Document.for_user(current_user).where(category: @category)
  end

  def set_category_and_documents
    @category = "Taxes"
    @documents = Document.for_user(current_user).where(category: @category)
  end
end
