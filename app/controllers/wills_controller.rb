class WillsController < ApplicationController
  before_action :set_will, :set_document_params, only: [:show, :edit, :update, :destroy]
  before_action :set_contacts, only: [:new, :create, :edit, :update]
  before_action :set_ret_url
  before_action :set_document_params, only: [:index]

  # GET /wills
  # GET /wills.json
  def index
    @wills = Will.for_user(current_user)
  end

  # GET /wills/1
  # GET /wills/1.json
  def show
  end

  # GET /wills/new
  def new
    @will = Will.new
    @vault_entry = WillBuilder.new(type: 'will').build
    @vault_entry.vault_entry_contacts.build
    @vault_entry.vault_entry_beneficiaries.build
    @wills = Will.for_user(current_user)
  end

  # GET /wills/1/edit
  def edit
  end
  
  def set_document_params
    @group = "Will"
    @category = Rails.application.config.x.WtlCategory
    @group_documents = DocumentService.new(:category => @category).get_group_documents(current_user, @group)
  end


  # POST /wills
  # POST /wills.json
  def create
    adjusted_params = will_params.merge(user_id: current_user.id)
    @vault_entry = WillBuilder.new(adjusted_params).build

    respond_to do |format|
      if @vault_entry.save
        format.html { redirect_to estate_planning_path, notice: 'Will was successfully created.' }
        format.json { render :show, status: :created, location: @will }
      else
        format.html { render :new }
        format.json { render json: @will.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wills/1
  # PATCH/PUT /wills/1.json
  def update
    respond_to do |format|
      if @will.update(will_params)
        format.html { redirect_to @will, notice: 'Will was successfully updated.' }
        format.json { render :show, status: :ok, location: @will }
      else
        format.html { render :edit }
        format.json { render json: @will.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wills/1
  # DELETE /wills/1.json
  def destroy
    @will.destroy
    respond_to do |format|
      format.html { redirect_to wills_url, notice: 'Will was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def get_wills_details
    render :json => WtlService.get_wills_details(Will.for_user(current_user))
  end
  
  def set_group
    @group = "Will"
  end

  def set_ret_url
    session[:ret_url] = wills_path
  end

  private

  def current_wtl
    params[:will]
  end

  def vault_entry_params
    params.require(:will).permit!
  end

  private
    def set_contacts
      @contacts = Contact.for_user(current_user)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_will
      @will = Will.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def will_params
      params.require(:will).permit!
    end
end
