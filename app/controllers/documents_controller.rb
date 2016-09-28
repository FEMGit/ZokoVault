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
  end

  def edit
    @shares = @document.shares
  end

  def create
    @document = Document.new(document_params.merge(user_id: current_user.id))
    clear_notes_field
    respond_to do |format|
      if @document.save #TODO: dynamic route builder for categories
        if return_url?
          format.html { redirect_to edit_document_path(@document), notice: 'Document was successfully created.' }
        else
          format.html { redirect_to edit_document_path(@document), notice: 'Document was successfully created.' }
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
      if @document.update(document_params)
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

  private

  def set_document
    @document = Document.for_user(current_user).find(params[:id])
  end

  def base_params
    params.permit(:group, :category)
  end

  def document_params
    params.require(:document).permit(:name, :description, :url, :category, :contact_ids, 
                                     shares_attributes: [:user_id, :contact_id])
  end
  
  def return_url?
    %w[/insurance /estate_planning].include? session[:ret_url]
  end
  
  def clear_notes_field
    @document.description = ""
  end
end
