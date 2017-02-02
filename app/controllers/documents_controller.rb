class DocumentsController < AuthenticatedController
  include SharedViewModule
  include DocumentsHelper
  before_action :set_document, only: [:show, :edit, :update, :destroy]
  before_action :set_contacts, only: [:new, :create, :edit, :update]
  before_action :set_viewable_contacts, only: [:update, :edit]
  before_action :prepare_document_params, only: [:create, :update]
  before_action :set_shared_view_settings, :set_dropdown_options, only: [:new, :edit]
  
  # Breadcrumbs navigation
  before_action :set_previous_crumbs, only: [:new, :edit]
  add_breadcrumb "Documents", :documents_path, only: [:index]
  before_action :set_add_crumbs, only: [:new]
  before_action :set_edit_crumbs, only: [:edit]
  include BreadcrumbsCacheModule

  def set_previous_crumbs
    return unless request.referrer.present?
    @breadcrumbs = BreadcrumbsCacheModule.cache_breadcrumbs_pop(current_user, @shared_user)
  end
  
  def set_add_crumbs
    add_breadcrumb "Add Document", new_documents_path(@shared_user)
  end
  
  def set_edit_crumbs
    add_breadcrumb "Edit Document", edit_documents_path(@document, @shared_user)
  end

  @after_new_user_created = ""

  def index
    @documents = policy_scope(Document).each { |d| authorize d }
    session[:ret_url] = "/documents"
  end

  def show
    authorize @document
  end

  def new
    @document = Document.new(base_params.slice(:category, :group, :vendor_id, :financial_information_id).merge(user: resource_owner))

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
    options = document_params.merge(user: resource_owner)
    @document = Document.new(options)
    set_viewable_contacts

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
  
  def set_dropdown_options
    @category_dropdown_options = 
    if base_params[:category].present?
      [base_params[:category]]
    else
     (resource_owner != current_user) ? @shared_category_names_full.prepend('Select...') : CategoryDropdownOptions::CATEGORIES
    end
  end
  
  def set_shared_view_settings
    return unless resource_owner != current_user
    @shared_user = resource_owner
    @shared_category_names_full = ResourceOwnerService.shared_category_names(resource_owner, current_user)
  end

  def card_values(category)
    service = DocumentService.new(:category => category)
    service.get_card_values(resource_owner, current_user)
  end
  
  def card_names(category)
    service = DocumentService.new(:category => category)
    service.get_card_names(resource_owner, current_user)
  end
  
  def shared_user_params
    params.permit(:shared_user_id)
  end

  def resource_owner
    if shared_user_params[:shared_user_id].present?
      User.find_by(id: params[:shared_user_id])
    else
      @document.present? ? @document.user : current_user
    end
  end

  def set_contacts
    contact_service = ContactService.new(:user => resource_owner)
    @contacts = contact_service.contacts
    @contacts_shareable = contact_service.contacts_shareable
  end
  
  def set_viewable_contacts
    share_contact_ids = document_shares(@document).map(&:contact_id).select { |c| Contact.exists? id: c }
    @document.contact_ids |= share_contact_ids
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
    
    viewable_shares = document_shares(@document).map(&:contact_id).map(&:to_s)
    share.reject! { |k, v| viewable_shares.include? v["contact_id"] }
    
    document_params.merge(:shares_attributes => share, :user_id => resource_owner.id, :group => base_params[:group])
  end

  def document_params
    params.require(:document).permit(:name, :description, :url, :category, :user_id, :contact_ids, :vendor_id, :financial_information_id,
                                     shares_attributes: [:user_id, :contact_id])
  end

  def return_url?
    return if session[:ret_url].blank?

    %w[/contacts /insurance /documents /estate_planning].any? {|ret| session[:ret_url].start_with?(ret)} || :return_after_new_user
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
    if DocumentService.update_group?(base_params[:group], document_params[:category])
      params[:document][:vendor_id] = nil
      params[:document][:financial_information_id] = nil
    else
      params[:group] = DocumentService.empty_value
    end
  end

  def handle_document_saved(format)
    #TODO: dynamic route builder for categories
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
    format.html { render :new, :layout => set_layout }
    format.json { render json: @document.errors, status: :unprocessable_entity }
  end
  
  def handle_document_not_updated(format)
    @cards = card_values(@document.category)
    @card_names = card_names(@document.category)
    format.html { render :edit, :layout => set_layout }
    format.json { render json: @document.errors, status: :unprocessable_entity }
  end
end
