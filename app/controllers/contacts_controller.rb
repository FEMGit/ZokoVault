class ContactsController < AuthenticatedController
  before_action :set_contact, only: [:show, :edit, :update, :destroy]

  # GET /contacts
  # GET /contacts.json
  def index
    @contacts = Contact.for_user(current_user)
    session[:ret_url] = "/contacts"
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
    @contact_documents = get_contact_share_documents
    ventries = get_primary_contact_documents
    session[:ret_url] = "/contacts/#{@contact.id}"
  end

  # GET /contacts/new
  def new
    @contact = Contact.new
  end

  # GET /contacts/1/edit
  def edit
  end

  # POST /contacts
  # POST /contacts.json
  def create
    @contact = Contact.new(contact_params.merge(user_id: current_user.id))
    respond_to do |format|
      if @contact.save
        UpdateDocumentService.new(:user => current_user, :contact => @contact.id, :ret_url => session[:ret_url]).update_document
        format.html { redirect_to session[:ret_url] || @contact, notice: 'Contact was successfully created.' }
        format.json { render :show, status: :created, location: @contact }
      else
        format.html { render :new }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
      session[:ret_after_new_user] = session[:ret_url]
    end
  end

  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    respond_to do |format|
      if @contact.update(contact_params)
        format.html { redirect_to @contact, notice: 'Contact was successfully updated.' }
        format.json { render :show, status: :ok, location: @contact }
      else
        format.html { render :edit }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact.destroy
    respond_to do |format|
      format.html { redirect_to contacts_url, notice: 'Contact was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      @contact = Contact.find(params[:id])
    end
  
    def get_contact_share_documents
      Document.for_user(current_user).select{|doc| doc.shares.any?{|sh| sh.contact_id == @contact.id}}
    end
  
    def get_primary_contact_documents
      Document.for_user(current_user).select{|doc| doc.shares.any?{|sh| sh.contact_id == @contact.id}}
    end
  
    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_params
      params.require(:contact).permit(:firstname, :lastname, :emailaddress, :phone, :contact_type, :relationship, :beneficiarytype, :ssn, :birthdate, :address, :zipcode, :city,
                                      :state, :notes, :avatarcolor, :photourl, :businessname, :businesswebaddress, :business_street_address_1, :business_street_address_2, :businessphone, :businessfax)
    end
end
