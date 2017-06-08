class ContactsController < AuthenticatedController
  before_action :set_contact, only: [:show, :edit, :update, :destroy]
  before_action :my_profile_contact?, only: [:show, :edit]
  before_action :set_contact_shares, only: [:show]
  include SanitizeModule

  # Breadcrumbs navigation
  add_breadcrumb "Contacts & Permissions", :contacts_path, only: [:index, :show, :new, :edit]
  before_action :set_details_crumbs, only: [:show]
  include BreadcrumbsCacheModule
  include UserTrafficModule

  def page_name
    case action_name
      when 'index'
        return "Documents"
      when 'new'
        return "Create Contact"
      when 'edit'
        contact = Contact.for_user(resource_owner).friendly.find_or_return_nil(params[:id])
        return "Contacts - #{contact.name} - Edit"
      when 'show'
        contact = Contact.for_user(resource_owner).friendly.find_or_return_nil(params[:id])
        return "Contacts - #{contact.name} - Details"
    end
  end

  def set_details_crumbs
    return unless @contact.present?
    add_breadcrumb @contact.name.to_s, contact_path(@contact)
  end

  # GET /contacts
  # GET /contacts.json
  def index
    my_profile_contact = resource_owner.user_profile.contact
    @contacts = Contact.for_user(resource_owner)
                       .reject { |c| c == my_profile_contact }
                       .each { |c| authorize c }
    session[:ret_url] = contacts_path
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
    authorize @contact

    session[:ret_url] = contact_path(@contact)
  end

  # GET /contacts/new
  def new
    set_redirect_new_user_creating
    @contact = Contact.new(user: resource_owner)

    authorize @contact
  end

  # GET /contacts/1/edit
  def edit;
    @contact_relationship = @contact.relationship
  end

  # POST /contacts
  # POST /contacts.json
  def create
    @contact = Contact.new(contact_params.merge(user: resource_owner))

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

  def relationship_values
    render :json => Contact::CONTACT_TYPES[contact_type_params[:contact_type]]
  end

  private

    def set_contact_shares
      return [] unless @contact.present?
      share_documents = ShareService.shared_documents_by_contact(resource_owner, @contact)
      share_categories = ShareService.shared_categories(resource_owner, nil, @contact).map! { |x| Category.fetch(x.downcase) }
      share_cards = ShareService.shared_cards(resource_owner, nil, @contact)
      @shares = share_documents + share_categories + share_cards
      @contact_documents = DocumentService.contact_documents(resource_owner, @category, @contact.id)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      @category = "Contact"
      @contact = Contact.for_user(resource_owner).friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_params
      params.require(:contact).permit(:firstname, :lastname, :emailaddress, :phone, :contact_type, :relationship, :beneficiarytype, :ssn, :birthdate, :address, :zipcode, :city,
                                      :state, :notes, :avatarcolor, :photourl, :businessname, :businesswebaddress, :business_street_address_1, :business_street_address_2, :businessphone, :businessfax, :redirect)
    end

    def shared_user_params
      params.permit(:shared_user_id)
    end

    def contact_type_params
      params.permit(:contact_type)
    end

    def resource_owner
      if shared_user_params[:shared_user_id].present?
        User.find_by(id: params[:shared_user_id])
      else
        @contact.present? ? @contact.user : current_user
      end
    end

    def set_redirect_new_user_creating
      return unless params[:redirect]
      Rails.cache.write('after_new_user_created', params[:redirect])
    end

    def get_redirect_new_user_creating
      Rails.cache.read('after_new_user_created')
    end

    def my_profile_contact?
      redirect_to contacts_path if @contact == resource_owner.user_profile.contact
    end

    def handle_contact_not_saved(format)
      format.html { render :new }
      format.json { render json: @contact.errors, status: :unprocessable_entity }
      format.js { render json: @contact.errors, status: :unprocessable_entity }
    end

    def handle_contact_saved(format)
      UpdateDocumentService.new(:user => resource_owner, :contact => @contact.id, :ret_url => session[:ret_url]).update_document
      format.html { redirect_to session[:ret_url] || @contact, redirect: get_redirect_new_user_creating, flash: { success: 'Contact was successfully created.' } }
      format.json { render :show, status: :created, location: @contact }
      
      contact_ids = Contact.for_user(resource_owner).sort_by { |s| s.lastname.downcase }.map(&:id)
      contact_position = contact_ids.find_index(@contact.id)
      general_after_id = general_after_id(contact_ids, contact_position)
      after_contact = Contact.find_by(id: general_after_id)
      
      if after_contact && after_contact.account_owner?
        shared_after_id = share_contact_after_id(contact_ids, contact_position)
      end
      
      format.js { render json: @contact.slice(:id, :firstname, :lastname, :relationship, :emailaddress).merge(:position => general_after_id, shared_position: shared_after_id), status: :ok }
    end
  
  def general_after_id(contact_ids, contact_position)
    contact_after_id(contact_ids, contact_position - 1)
  end
  
  def share_contact_after_id(contact_ids, contact_position)
    contact_after_id(contact_ids, contact_position - 2)
  end
  
  def contact_after_id(contact_ids, contact_position)
    if contact_position < 0
      'create_new_contact'
    else
      contact_ids[contact_position]
    end
  end
end
