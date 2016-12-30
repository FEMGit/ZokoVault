class DocumentsController < AuthenticatedController
  before_action :set_document, only: [:show, :edit, :update, :destroy]
  before_action :set_contacts, only: [:new, :create, :edit, :update]
  before_action :prepare_document_params, only: [:create, :update]
  
  # Breadcrumbs navigation
  add_breadcrumb "Documents", :documents_path, :only => %w(new edit)

  @after_new_user_created = ""

  def index
    @documents = policy_scope(Document).each { |d| authorize d }
    session[:ret_url] = "/documents"
  end

  def show
    authorize @document
  end

  def new
    @document = Document.new(base_params.slice(:category, :group, :vendor_id, :financial_information_id).merge(user: current_user))

    authorize @document

    @cards = card_values(@document.category)
    @card_names = card_names(@document.category)
  end

  def edit
    authorize @document

    session[:ret_url] = get_return_url_path
    @shares = @document.shares
    @card_names = card_names(@document.category)
  end

  def create
    options = document_params.merge(user: current_user)
    @document = Document.new(options)

    authorize @document

    respond_to do |format|
      if @document.save && @document.update(document_share_params)
        handle_document_saved(format)
      else
        handle_document_not_saved(format)
      end
    end
  end

  def update
    authorize @document

    respond_to do |format|
      if is_new_contact_creating
        save_return_url_path(params[:id])

        format.html { redirect_to new_contact_path :redirect => @after_new_user_created }
      end

      set_document_update_date_to_now(@document)
      if @document.update(document_share_params)
        if return_url?
          format.html { redirect_to session[:ret_url], flash: { success: 'Document was successfully updated.' } }
        else
          format.html { redirect_to documents_path, flash: { success: 'Document was successfully updated.' } }
        end
        format.json { render :show, status: :ok, location: @document }
      else
        handle_document_not_updated(format)
      end
    end
  end

  def destroy
    authorize @document

    @document.destroy
    S3Service.delete_from_storage(@document.url)
    redirect_page = session[:ret_url] || documents_path
    respond_to do |format|
      format.html { redirect_to redirect_page, notice: 'Document was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def get_drop_down_options
    render :json => card_values(base_params[:category]).flatten
  end
  
  def get_card_names
    render :json => card_names(base_params[:category]).flatten
  end

  private

  def card_values(category)
    service = DocumentService.new(:category => category)
    service.get_card_values(resource_owner)
  end
  
  def card_names(category)
    service = DocumentService.new(:category => category)
    service.get_card_names(resource_owner)
  end

  def resource_owner
    @document.present? ? @document.user : current_user
  end

  def set_contacts
    contact_service = ContactService.new(:user => resource_owner)
    @contacts = contact_service.contacts
    @contacts_shareable = contact_service.contacts_shareable
  end

  def set_document
    @document = Document.find(params[:id])
    @cards = card_values(@document.category)
  end

  def base_params
    params.permit(:group, :category, :vendor_id, :financial_information_id)
  end
  
  def document_share_params
    share_service = ShareService.new(user_id: resource_owner.id, contact_ids: params[:document][:contact_ids])
    share = share_service.fill_document_share
    #cleare document shares before updating current document
    share_service.clear_shares(@document)
    document_params.merge(:shares_attributes => share, :user_id => resource_owner.id)
  end

  def document_params
    params.require(:document).permit(:name, :description, :url, :category, :user_id, :group, :contact_ids, :vendor_id, :financial_information_id,
                                     shares_attributes: [:user_id, :contact_id])
  end

  def return_url?
    return if session[:ret_url].blank?

    %w[/contacts /insurance /documents /estate_planning].any? {|ret| session[:ret_url].start_with?(ret)} || :return_after_new_user
  end
  
  def is_new_contact_creating
    params_to_test = params[:document][:contact_ids]
    is_new = params_to_test && params_to_test.any? {|value| value == 'create_new_contact'}
    #remove 'create new contact' field from parameters
    if is_new
      params[:document][:contact_ids].delete_if{|value| value == 'create_new_contact'}
    end
    is_new
  end

  def save_return_url_path(document_id_to_change)
    @after_new_user_created = session[:ret_url]
    session[:ret_url] = "/documents/" + document_id_to_change.to_s + "/edit"
  end
  
  def get_return_url_path
    url = Rails.cache.read('after_new_user_created') || session[:ret_url]
    Rails.cache.delete('after_new_user_created')
    url
  end
  
  def document_clean_from_create_new_user_id
    params[:document][:shares_attributes].delete_if{|k, v| v[:contact_id] == new_contact_path}
  end
  
  def set_document_update_date_to_now(document)
    document.updated_at = Time.now.utc
  end
  
  def prepare_document_params
    if document_params[:vendor_id].present?
      insurance_service = InsuranceService.new(current_user)
      params[:document][:group] = insurance_service.group_by_vendor(document_params[:vendor_id])
    end
  end

  def handle_document_saved(format)
    #TODO: dynamic route builder for categories
    if is_new_contact_creating
      save_return_url_path(@document.id)
      format.html { redirect_to new_contact_path :redirect => @after_new_user_created }
    end
    if return_url?
      format.html { redirect_to session[:ret_url], flash: { success: 'Document was successfully created.' } }
    else
      format.html { redirect_to documents_path, flash: { success: 'Document was successfully created.' } }
    end
    format.json { render :show, status: :created, location: @document }
  end

  def handle_document_not_saved(format)
    @cards = card_values(@document.category)
    @card_names = card_names(@document.category)
    format.html { render :new }
    format.json { render json: @document.errors, status: :unprocessable_entity }
  end
  
  def handle_document_not_updated(format)
    @cards = card_values(@document.category)
    @card_names = card_names(@document.category)
    format.html { render :edit }
    format.json { render json: @document.errors, status: :unprocessable_entity }
  end
end
