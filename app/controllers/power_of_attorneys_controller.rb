class PowerOfAttorneysController < ApplicationController
  before_action :set_power_of_attorney, :set_document_params, only: [:show, :edit, :update, :destroy]
  before_action :set_document_params, only: [:index]

  # GET /power_of_attorneys
  # GET /power_of_attorneys.json
  def index
    @power_of_attorneys = PowerOfAttorney.all
  end

  # GET /power_of_attorneys/1
  # GET /power_of_attorneys/1.json
  def show
  end

  # GET /power_of_attorneys/new
  def new
    @vault_entry = PowerOfAttorneyBuilder.new.build
    @vault_entry.vault_entry_contacts.build
  end

  # GET /power_of_attorneys/1/edit
  def edit
  end
  
  def set_document_params
    @group = "Legal"
    @category = Rails.application.config.x.WtlCategory
    @group_documents = DocumentService.new(:category => @category).get_group_documents(current_user, @group)
  end

  # POST /power_of_attorneys
  # POST /power_of_attorneys.json
  def create
    adjusted_params = power_of_attorney_params.merge(user_id: current_user.id)
    @vault_entry = PowerOfAttorneyBuilder.new(adjusted_params).build

    respond_to do |format|
      if @vault_entry.save
        format.html { redirect_to estate_planning_path, notice: 'Power of Attorney was successfully created.' }
        format.json { render :show, status: :created, location: @power_of_attorney }
      else
        format.html { render :new }
        format.json { render json: @power_of_attorney.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /power_of_attorneys/1
  # PATCH/PUT /power_of_attorneys/1.json
  def update
    respond_to do |format|
      if @power_of_attorney.update(power_of_attorney_params)
        format.html { redirect_to @power_of_attorney, notice: 'Power of attorney was successfully updated.' }
        format.json { render :show, status: :ok, location: @power_of_attorney }
      else
        format.html { render :edit }
        format.json { render json: @power_of_attorney.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /power_of_attorneys/1
  # DELETE /power_of_attorneys/1.json
  def destroy
    @power_of_attorney.destroy
    respond_to do |format|
      format.html { redirect_to power_of_attorneys_url, notice: 'Power of attorney was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def set_ret_url
    session[:ret_url] = "/power_of_attorneys/details/#{current_wtl}"
  end

  def details
  end

  private

    def current_wtl
      params[:attorney]
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_power_of_attorney
      @power_of_attorney = PowerOfAttorney.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def power_of_attorney_params
      params.require(:power_of_attorney).permit!
    end
end
