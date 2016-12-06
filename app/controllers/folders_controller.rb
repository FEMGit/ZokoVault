class FoldersController < AuthenticatedController
  before_action :set_folder, only: [:show, :edit, :update, :destroy]
  before_action :set_new_folder, only: [:new]
  before_action :set_ret_url, only: [:new, :edit, :show]

  def index
    @folders = Folder.just_folders.for_user(current_user)
  end

  def show; end

  def new; end

  def edit; end

  def create
    parent = Folder.find_by_id(params[:folder].delete(:parent_id))
    @folder = parent.children.build(folder_params)
    @folder.user = current_user

    respond_to do |format|
      if @folder.save
        format.html { redirect_to folders_url, notice: 'Folder was successfully created.' }
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
  
  def set_new_folder
    @folder = Folder.new(parent_id: params[:parent_id])
  end

  def set_folder
    @folder = Folder.for_user(current_user).find(params[:id])
  end
  
  def set_ret_url
    return unless @folder.parent.present?
    session[:ret_url] = path_helper(@folder.parent)
  end

  def folder_params
    params.require(:folder).permit(:name, :description, :system)
  end
end
