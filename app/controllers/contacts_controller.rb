class ContactsController < AuthenticatedController
  before_action :set_contact, only: [:show, :edit, :update, :destroy]
  before_action :my_profile_contact?, only: [:show, :edit]
  
  # Breadcrumbs navigation
  add_breadcrumb "Contacts & Permissions", :contacts_path, :only => %w(show)

  # GET /contacts
  # GET /contacts.json
  def index
    my_profile_contact = current_user.user_profile.contact
    @contacts = Contact.for_user(current_user)
                       .reject { |c| c == my_profile_contact }
                       .each { |c| authorize c }
    session[:ret_url] = "/contacts"
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
    authorize @contact

    @share_documents = DocumentService.get_share_with_documents(current_user, @contact.id)
    @contact_documents = DocumentService.get_contact_documents(current_user, @category, @contact.id)
    session[:ret_url] = "/contacts/#{@contact.id}"
  end

  # GET /contacts/new
  def new
    set_redirect_new_user_creating
    @contact = Contact.new(user: current_user)
    
    authorize @contact
  end

  # GET /contacts/1/edit
  def edit; end

  # POST /contacts
  # POST /contacts.json
  def create
    @contact = Contact.new(contact_params.merge(user: current_user))

    authorize @contact

    respond_to do |format|
      if @contact.save
        handle_contact_saved(format)
      else
        handle_contact_not_saved(format)
      end
      session[:ret_after_new_user] = session[:ret_url]
    end
  end

  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    authorize @contact

    respond_to do |format|
      if @contact.update(contact_params)
        format.html { redirect_to @contact, flash: { success: 'Contact was successfully updated.' } }
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
    authorize @contact

    @contact.destroy
    respond_to do |format|
      format.html { redirect_to contacts_url, notice: 'Contact was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      @category = "Contact"
      @contact = Contact.for_user(current_user).find(params[:id])
    end
  
    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_params
      params.require(:contact).permit(:firstname, :lastname, :emailaddress, :phone, :contact_type, :relationship, :beneficiarytype, :ssn, :birthdate, :address, :zipcode, :city,
                                      :state, :notes, :avatarcolor, :photourl, :businessname, :businesswebaddress, :business_street_address_1, :business_street_address_2, :businessphone, :businessfax, :redirect)
    end
  
    def set_redirect_new_user_creating
      return unless params[:redirect]
      Rails.cache.write('after_new_user_created', params[:redirect])
    end
  
    def get_redirect_new_user_creating
      Rails.cache.read('after_new_user_created')
    end
  
    def my_profile_contact?
      redirect_to contacts_path if @contact == current_user.user_profile.contact
    end

    def handle_contact_not_saved(format)
      format.html { render :new }
      format.json { render json: @contact.errors, status: :unprocessable_entity }
      format.js { render json: @contact.errors, status: :unprocessable_entity }
    end

    def handle_contact_saved(format)
      UpdateDocumentService.new(:user => current_user, :contact => @contact.id, :ret_url => session[:ret_url]).update_document
      format.html { redirect_to session[:ret_url] || @contact, redirect: get_redirect_new_user_creating, flash: { success: 'Contact was successfully created.' } }
      format.json { render :show, status: :created, location: @contact }
      contact_dropdown_position = Contact.for_user(current_user).sort_by { |s| s.lastname }.map(&:id).find_index(@contact.id)
      format.js { render json: @contact.slice(:id, :firstname, :lastname).merge(:position => contact_dropdown_position), status: :ok }
    end
end
