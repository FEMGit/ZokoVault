class TrustsController < AuthenticatedController
  before_action :set_trust, :set_document_params, only: [:show, :edit, :update, :destroy]
  before_action :set_contacts, only: [:new, :create, :edit, :update]
  before_action :set_ret_url
  before_action :set_document_params, only: [:index]

  # GET /trusts
  # GET /trusts.json
  def index
    @trusts = Trust.for_user(current_user)
  end

  # GET /trusts/1
  # GET /trusts/1.json
  def show
  end

  # GET /trusts/new
  def new
    @vault_entry = TrustBuilder.new(type: 'trust').build
    @vault_entry.vault_entry_contacts.build
    @trusts = Trust.for_user(current_user)
  end

  # GET /trusts/1/edit
  def edit
  end
  
  def set_document_params
    @group = "Trust"
    @category = Rails.application.config.x.WtlCategory
    @group_documents = DocumentService.new(:category => @category).get_group_documents(current_user, @group)
  end

  # POST /trusts
  # POST /trusts.json
  def create
    adjusted_params = trust_params.merge(user_id: current_user.id)
    @vault_entry = TrustBuilder.new(adjusted_params).build

    respond_to do |format|
      if @vault_entry.save
        format.html { redirect_to estate_planning_path, notice: 'Trust was successfully created.' }
        format.json { render :show, status: :created, location: @trust }
      else
        format.html { render :new }
        format.json { render json: @trust.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trusts/1
  # PATCH/PUT /trusts/1.json
  def update
    respond_to do |format|
      if @trust.update(trust_params)
        format.html { redirect_to @trust, notice: 'Trust was successfully updated.' }
        format.json { render :show, status: :ok, location: @trust }
      else
        format.html { render :edit }
        format.json { render json: @trust.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trusts/1
  # DELETE /trusts/1.json
  def destroy
    @trust.destroy
    respond_to do |format|
      format.html { redirect_to trusts_url, notice: 'Trust was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def set_ret_url
    session[:ret_url] = trusts_path
  end

  def get_trusts_details
    render :json => WtlService.get_trusts_details(Trust.for_user(current_user))
  end

  private
    def set_contacts
      @contacts = Contact.for_user(current_user)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_trust
      @group_documents = Document.for_user(current_user).where(:group => @group)
      @trust = Trust.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def trust_params
      params.require(:trust).permit!
    end
end
