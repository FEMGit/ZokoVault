class FinancialAccountController < AuthenticatedController
  before_action :set_provider, only: [:show, :edit, :update, :destroy_provider, :set_documents]
  before_action :initialize_category_and_group, :set_documents, only: [:show]
  before_action :set_contacts, only: [:new, :edit]
  before_action :set_account, only: [:destroy]
  
  # Breadcrumbs navigation
  add_breadcrumb "Financial Information", :financial_information_path, :only => %w(show new edit)
  add_breadcrumb "Financial Info - Add Account", :add_account_path, :only => %w(new)
  before_action :set_details_crumbs, only: [:edit, :show]
  before_action :set_edit_crumbs, only: [:edit]
  
  def set_details_crumbs
    add_breadcrumb "#{@financial_provider.name}", show_account_path(@financial_provider)
  end
  
  def set_edit_crumbs
    add_breadcrumb "Financial Info - Add Account", edit_account_path(@financial_provider)
  end
  
  def new
    @financial_provider = FinancialProvider.new(user: resource_owner)
    @financial_account = FinancialAccountInformation.new
    @financial_provider.accounts << @financial_account
    authorize @financial_provider
  end
  
  def show
    authorize @financial_provider
    session[:ret_url] = "#{financial_information_path}/account/#{params[:id]}"
  end
  
  def edit
    authorize @financial_provider
  end
  
  def create
    @financial_provider = FinancialProvider.new(provider_params.merge(user_id: current_user.id))
    authorize @financial_provider
    FinancialInformationService.fill_accounts(account_params, @financial_provider, current_user.id)
    respond_to do |format|
      if @financial_provider.save
        FinancialInformationService.update_shares(@financial_provider, current_user, @financial_provider.share_with_contact_ids)
        format.html { redirect_to show_account_url(@financial_provider), flash: { success: 'Account was successfully created.' } }
        format.json { render :show, status: :created, location: @financial_provider }
      else
        format.html { render :new }
        format.json { render json: @financial_provider.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    authorize @financial_provider
    FinancialInformationService.fill_accounts(account_params, @financial_provider, current_user.id)
    respond_to do |format|
      if @financial_provider.update(provider_params)
        FinancialInformationService.update_shares(@financial_provider, current_user, @financial_provider.share_with_contact_ids)
        format.html { redirect_to show_account_url(@financial_provider), flash: { success: 'Account was successfully updated.' } }
        format.json { render :show, status: :ok, location: @financial_provider }
      else
        format.html { render :edit }
        format.json { render json: @financial_provider.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    financial_provider = FinancialProvider.find_by(id: @account.account_provider_id)
    authorize financial_provider
    @account.destroy
    respond_to do |format|
      format.html { redirect_to :back || financial_information_path, notice: 'Account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # DELETE /provider/1
  def destroy_provider
    authorize @financial_provider
    @financial_provider.destroy
    respond_to do |format|
      format.html { redirect_to financial_information_path, notice: 'Provider was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  private
  
  def resource_owner
    @financial_provider.present? ? @financial_provider.user : current_user
  end
  
  def initialize_category_and_group
    @category = Rails.application.config.x.FinancialInformationCategory
    @group = "Account"
  end
  
  def set_account
    @account = FinancialAccountInformation.for_user(current_user).find(params[:id])
  end
  
  def set_provider
    @financial_provider = FinancialProvider.for_user(current_user).find(params[:id])
  end
  
  def set_documents
    @documents = Document.for_user(current_user).where(category: @category, financial_information_id: @financial_provider.id)
  end

  
  def provider_params
    params.require(:financial_provider).permit(:id, :name, :web_address, :street_address, :city, :state, :zip, :phone_number, :fax_number, :primary_contact_id, 
                                               share_with_contact_ids: [])
  end
  
  def account_params
    accounts = params[:financial_provider].select { |k, _v| k.starts_with?("account_") }
    permitted_params = {}
    accounts.keys.each do |policy_key|
      permitted_params[policy_key] = [:id, :account_type, :owner_id, :value, :number, :primary_contact_broker_id, :notes]
    end
    accounts.permit(permitted_params)
  end
  
  def set_contacts
    contact_service = ContactService.new(:user => current_user)
    @contacts = contact_service.contacts
    @contacts_shareable = contact_service.contacts_shareable
  end
end
