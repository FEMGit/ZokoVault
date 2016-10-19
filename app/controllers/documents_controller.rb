class DocumentsController < AuthenticatedController
  before_action :set_document, only: [:show, :edit, :update, :destroy]

  def index
    @documents = Document.for_user(current_user)
    session[:ret_url] = "/documents"
  end

  def show
  end

  def new
    @document = Document.new(base_params.slice(:category, :group))
    documents_helper = DocumentService.new(:category => @document.category);
    @cards = documents_helper.get_card_values
  end

  def edit
    @shares = @document.shares
  end

  def create
    @document = Document.new(document_params.merge(:user_id => current_user.id))
    respond_to do |format|
      if @document.save && @document.update(document_share_params) #TODO: dynamic route builder for categories
        if is_new_contact_creating
          save_return_url_path(@document.id)
          format.html { redirect_to new_contact_path }
        end
        if return_url?
          format.html { redirect_to session[:ret_url], notice: 'Document was successfully created.' }
        else
          format.html { redirect_to documents_path, notice: 'Document was successfully created.' }
        end
        format.json { render :show, status: :created, location: @document }
      else
        format.html { render :new }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if is_new_contact_creating
        save_return_url_path(current_document_id)
        format.html { redirect_to new_contact_path }
      end
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
    @document.destroy
    redirect_page = session[:ret_url] || documents_path
    respond_to do |format|
      format.html { redirect_to redirect_page, notice: 'Document was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def get_drop_down_options
    category = params[:category]
    documents_helper = DocumentService.new(:category => params[:category]);
    render :json => documents_helper.get_card_values
  end

  private

  def set_document
    @document = Document.for_user(current_user).find(params[:id])
    documents_helper = DocumentService.new(:category => @document.category);
    @cards = documents_helper.get_card_values
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
    if session[:ret_url]
      %w[/contacts /insurance /documents /estate_planning].any? {|ret| session[:ret_url].start_with?(ret)}
    else
      nil
    end
  end
  
  def current_document_id
    params[:id]
  end
  
  def is_new_contact_creating
    params_to_test = params[:document][:contact_ids]
    params_to_test && params_to_test.any? {|value| value == 'create_new_contact'}
  end

  def save_return_url_path (document_id_to_change)
    session[:ret_url] = "/documents/" + document_id_to_change.to_s + "/edit"
  end
  
  def document_clean_from_create_new_user_id
    params[:document][:shares_attributes].delete_if{|k, v| v[:contact_id] == new_contact_path}
  end
end
