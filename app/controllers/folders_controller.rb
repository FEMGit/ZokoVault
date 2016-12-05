class FoldersController < AuthenticatedController
  before_action :set_folder, only: [:show, :edit, :update, :destroy]

  def index
    @folders = Folder.just_folders.for_user(current_user)
  end

  def show
  end

  def new
    @folder = Folder.new(parent_id: params[:parent_id])
  end

  def edit
  end

  def create
    parent = Folder.find_by_id(params[:folder].delete(:parent_id))
    @folder = parent.children.build(folder_params)
    @folder.user = current_user

    respond_to do |format|
      if @folder.save
        format.html { redirect_to folders_url, :only_path => true, notice: 'Folder was successfully created.' }
        format.json { render :show, status: :created, location: @folder }
      else
        format.html { render :new }
        format.json { render json: @folder.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @folder.update(folder_params)
        format.html { redirect_to @folder, notice: 'Folder was successfully updated.' }
        format.json { render :show, status: :ok, location: @folder }
      else
        format.html { render :edit }
        format.json { render json: @folder.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @folder.destroy
    respond_to do |format|
      format.html { redirect_to folders_url, notice: 'Folder was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_folder
    @folder = Folder.for_user(current_user).find(params[:id])
  end

  def folder_params
    params.require(:folder).permit(:name, :description, :system)
  end
end
