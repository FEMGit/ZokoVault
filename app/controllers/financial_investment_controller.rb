class FinancialInvestmentController < AuthenticatedController
  before_action :initialize_category_and_group, :set_documents, only: [:show]
  before_action :set_financial_investment, only: [:show, :edit, :update, :destroy]
  before_action :set_contacts, only: [:new, :edit]
  
  def new
    @financial_investment = FinancialInvestment.new
  end
  
  def show
    session[:ret_url] = "#{financial_information_path}/investment/#{params[:id]}"
  end
  
  def edit; end
  
  def create
    @financial_investment = FinancialInvestment.new(property_params.merge(user_id: current_user.id))
    respond_to do |format|
      if @financial_investment.save
        format.html { redirect_to show_investment_url(@financial_investment), flash: { success: 'Investment was successfully created.' } }
        format.json { render :show, status: :created, location: @financial_investment }
      else
        set_contacts
        format.html { render :new }
        format.json { render json: @financial_investment.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    respond_to do |format|
      if @financial_investment.update(property_params.merge(user_id: current_user.id))
        format.html { redirect_to show_investment_url(@financial_investment), flash: { success: 'Investment was successfully updated.' } }
        format.json { render :show, status: :created, location: @financial_investment }
      else
        format.html { render :new }
        format.json { render json: @financial_investment.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @financial_investment.destroy
    respond_to do |format|
      format.html { redirect_to financial_information_path, notice: 'Investment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  
  def set_financial_investment
    @financial_investment = FinancialInvestment.for_user(current_user).find(params[:id])
  end
  
  def set_documents
    @documents = Document.for_user(current_user).where(category: @category, group: @group)
  end

  
  def initialize_category_and_group
    @category = Rails.application.config.x.FinancialInformationCategory
    @group = "Investment or Debt"
  end

  def property_params
    params.require(:financial_investment).permit(:id, :name, :web_address, :investment_type, :notes, :value, :owner_id, :city, :state, :zip, :address, :phone_number, :primary_contact_id,
                                                 share_with_contact_ids: [])
  end
  
  def set_contacts
    contact_service = ContactService.new(:user => current_user)
    @contacts = contact_service.contacts
    @contacts_shareable = contact_service.contacts_shareable
  end
end
