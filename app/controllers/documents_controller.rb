class DocumentsController < AuthenticatedController
  before_action :set_document, only: [:show, :edit, :update, :destroy]
  before_action :set_contacts, only: [:new, :create, :edit, :update]

  @after_new_user_created = ""

  def index
    @documents = policy_scope(Document).each { |d| authorize d }
    session[:ret_url] = "/documents"
  end

  def show
    authorize @document
  end

  def new
    @document = Document.new(base_params.slice(:category, :group).merge(user: current_user))

    authorize @document

    documents_helper = DocumentService.new(:category => @document.category);
    @cards = documents_helper.get_card_values(current_user)
  end

  def edit
    authorize @document

    session[:ret_url] = get_return_url_path
    @shares = @document.shares
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
          format.html { redirect_to session[:ret_url], notice: 'Document was successfully updated.' }
        else
          format.html { redirect_to documents_path, notice: 'Document was successfully updated.' }
        end
        format.json { render :show, status: :ok, location: @document }
      else
        format.html { render :edit }
        format.json { render json: @document.errors, status: :unprocessable_entity }
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
    category = params[:category]
    documents_helper = DocumentService.new(:category => params[:category], :user => current_user);
    render :json => documents_helper.get_card_values(current_user).flatten
  end

  private

  def set_contacts
    @contacts = Contact.for_user(current_user)
    @contacts_shareable = @contacts.reject { |c| c.emailaddress == current_user.email } 
  end

  def set_document
    @document = Document.for_user(current_user).find(params[:id])
    documents_helper = DocumentService.new(:category => @document.category);
    @cards = documents_helper.get_card_values(current_user)
  end

  def base_params
    params.permit(:group, :category)
  end
  
  def document_share_params
    share_service = ShareService.new(user_id: current_user.id, contact_ids: params[:document][:contact_ids])
    share = share_service.fill_document_share
    #cleare document shares before updating current document
    share_service.clear_shares(@document)
    document_params.merge(:shares_attributes => share, :user_id => current_user.id)
  end

  def document_params
    params.require(:document).permit(:name, :description, :url, :category, :user_id, :group, :contact_ids,
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

  def handle_document_saved(format)
    #TODO: dynamic route builder for categories
    if is_new_contact_creating
      save_return_url_path(@document.id)
      format.html { redirect_to new_contact_path :redirect => @after_new_user_created }
    end
    if return_url?
      format.html { redirect_to session[:ret_url], notice: 'Document was successfully created.' }
    else
      format.html { redirect_to documents_path, notice: 'Document was successfully created.' }
    end
    format.json { render :show, status: :created, location: @document }
  end

  def handle_document_not_saved(format)
    @cards = DocumentService.new(:category => @document.category).get_card_values(current_user)
    format.html { render :new }
    format.json { render json: @document.errors, status: :unprocessable_entity }
  end
end
