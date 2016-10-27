class PowerOfAttorneysController < AuthenticatedController
  before_action :set_power_of_attorney, :set_document_params, only: [:show, :edit, :update, :destroy]
  before_action :set_ret_url
  before_action :set_document_params, only: [:index]

  # GET /power_of_attorneys
  # GET /power_of_attorneys.json
  def index
    @power_of_attorneys = PowerOfAttorney.for_user(current_user)
  end

  # GET /power_of_attorneys/1
  # GET /power_of_attorneys/1.json
  def show
  end

  # GET /power_of_attorneys/new
  def new
    @vault_entry = PowerOfAttorneyBuilder.new.build
    @vault_entry.vault_entry_contacts.build
    @power_of_attorneys = PowerOfAttorney.for_user(current_user)
    @vault_entries = PowerOfAttorney.for_user(current_user)
    if(@vault_entries.empty?)
      @vault_entries << @vault_entry
    end
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
    new_attorneys = WtlService.get_new_records(power_of_attorney_params)
    old_attorneys = WtlService.get_old_records(power_of_attorney_params)
    respond_to do |format|
      if(!new_attorneys.empty? || !old_attorneys.empty?)
        new_attorneys.each do |new_attorney_params|
          @new_vault_entries = PowerOfAttorneyBuilder.new(new_attorney_params.merge(user_id: current_user.id)).build 
          @new_vault_entries.save!
        end
        old_attorneys.each do |old_attorney|
          @old_vault_entries = PowerOfAttorneyBuilder.new(old_attorney.merge(user_id: current_user.id)).build
          @old_vault_entries.save
        end
        format.html { redirect_to estate_planning_path, notice: 'Power of Attorney was successfully created.' }
        format.json { render :show, status: :created, location: @power_of_attorney }
      else
        format.html { redirect_to :new }
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
  
  def get_powers_of_attorney_details
    render :json => WtlService.get_powers_of_attorney_details(PowerOfAttorney.for_user(current_user))
  end

  def set_ret_url
    session[:ret_url] = power_of_attorneys_path
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
      params.select {|x| x.starts_with?("vault_entry")}
    end
end