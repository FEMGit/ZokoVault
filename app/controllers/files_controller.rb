class FilesController < ApplicationController
  before_action :set_file, only: [:show, :edit, :update, :destroy]

  # GET /files
  def index
    @files = VaultFile.all
  end

  # GET /files/1
  def show
  end

  # GET /files/new
  def new
    @file = VaultFile.new
  end

  # GET /files/1/edit
  def edit
  end

  # POST /files
  def create
    @file = VaultFile.new(post_file_params)

    if @file.save
      redirect_to @file, notice: 'Upload was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /files/1
  def update
    if @file.update(post_file_params)
      redirect_to @file, notice: 'Upload attachment was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /files/1
  def destroy
    @file.destroy
    redirect_to uploads_url, notice: 'Upload was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_file
      @file = VaultFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_file_params
      params.require(:file).permit(:name)
    end
end
