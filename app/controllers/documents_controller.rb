class DocumentsController < AuthenticatedController
  before_action :set_document, only: [:show, :edit, :update, :destroy]

  def index
    @documents = Document.for_user(current_user)
  end

  def show
  end

  def new
    @folder = Folder.find_by_id(params[:folder_id])
    @document = Document.new(folder_id: params[:folder_id])
  end

  def edit
    @shares = @document.shares
  end

  def create
    folder = Folder.find_by_id(params[:folder_id])
    @document = Document.new(document_params)
    @document.folder = folder
    @document.user = current_user

    respond_to do |format|
      if @document.save
        format.html { redirect_to folder_document_path(@document.folder, @document), notice: 'Document was successfully created.' }
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
        format.html { redirect_to folder_document_path(@document.folder, @document), notice: 'Document was successfully updated.' }
        format.json { render :show, status: :ok, location: @document }
      else
        format.html { render :edit }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    folder = @document.folder
    @document.destroy
    respond_to do |format|
      format.html { redirect_to folder_path(folder), notice: 'Document was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_document
    @document = Document.for_user(current_user).find(params[:id])
  end

  def document_params
    params.require(:document).permit(:name, :url)
  end
end
