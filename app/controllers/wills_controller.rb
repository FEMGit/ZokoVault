class WillsController < AuthenticatedController
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
    @vault_entry = WillBuilder.new(type: 'will').build
    @vault_entry.vault_entry_contacts.build
    @vault_entry.vault_entry_beneficiaries.build
    @wills = Will.for_user(current_user)
    @vault_entries = Will.for_user(current_user)
    return unless @vault_entries.empty?
    @vault_entries << @vault_entry
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
    new_wills = WtlService.get_new_records(will_params)
    old_wills = WtlService.get_old_records(will_params)
    respond_to do |format|
      if new_wills.any? || old_wills.any?
        begin
          update_wills(new_wills, old_wills)
          format.html { redirect_to estate_planning_path, notice: 'Will was successfully created.' }
          format.json { render :show, status: :created, location: @will }
        rescue
          format.html { render :new }
          format.json { render json: @will.errors, status: :unprocessable_entity }
        end
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
      format.html { redirect_to :back || wills_url, notice: 'Will was successfully destroyed.' }
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
      contact_service = ContactService.new(:user => current_user)
      @contacts = contact_service.contacts
      @contacts_shareable = contact_service.contacts_shareable
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_will
      @will = Will.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def will_params
      params.select { |x| x.starts_with?("vault_entry") }
    end

    def update_wills(new_wills, old_wills)
      new_wills.each do |new_will_params|
        @new_vault_entries = WillBuilder.new(new_will_params.merge(user_id: current_user.id)).build
        raise "error saving new will" unless @new_vault_entries.save
      end
      old_wills.each do |old_will|
        @old_vault_entries = WillBuilder.new(old_will.merge(user_id: current_user.id)).build
        raise "error saving new will" unless @old_vault_entries.save
      end
    end
end
