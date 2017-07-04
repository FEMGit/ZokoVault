class ContactsController < AuthenticatedController
  before_action :set_contact, only: [:show, :edit, :update, :destroy]
  before_action :contact_rejected?, only: [:show, :edit]
  before_action :set_contact_shares, only: [:show]
  include SanitizeModule
  include SharedViewModule

  # Breadcrumbs navigation
  before_action :set_index_crumbs, only: [:index, :show, :new, :edit]
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
        contact = Contact.for_user(resource_owner).find_by(id: params[:id])
        return "Contacts - #{contact.name} - Edit"
      when 'show'
        contact = Contact.for_user(resource_owner).find_by(id: params[:id])
        return "Contacts - #{contact.name} - Details"
    end
  end
  
  def set_index_crumbs
    add_breadcrumb "Contacts & Permissions", contacts_path if general_view?
    add_breadcrumb "Contacts & Permissions", shared_view_contacts_path(@shared_user) if shared_view?
  end

  def set_details_crumbs
    return unless @contact.present?
    add_breadcrumb "#{@contact.name.to_s}", contact_details_path(@contact) if general_view?
    add_breadcrumb "#{@contact.name.to_s}", contact_details_path(@contact, @shared_user) if shared_view?
  end

  # GET /contacts
  # GET /contacts.json
  def index
    @contacts = Contact.for_user(resource_owner)
                       .reject { |c| contact_emails_rejected.include? c.emailaddress.downcase }
                       .each { |c| authorize c }
    session[:ret_url] = contacts_path
  end
  
  # GET /contacts/1
  # GET /contacts/1.json
  def show
    authorize @contact

    session[:ret_url] = contact_details_path(@contact, @shared_user)
  end

  # GET /contacts/new
  def new
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
        format.html { redirect_to success_path(contact_details_path(@contact), contact_details_path(@contact, @shared_user)), flash: { success: 'Contact was successfully updated.' } }
        format.json { render :show, status: :ok, location: @contact }
      else
        error_path(:edit)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout] }
        format.json { render json: @contact.errors , status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    authorize @contact

    @contact.destroy
    respond_to do |format|
      format.html { redirect_to @shared_user.present? ? shared_view_contacts_url : contacts_url, notice: 'Contact was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def relationship_values
    render :json => Contact::CONTACT_TYPES[contact_type_params[:contact_type]]
  end

  private
  
  def error_path(action)
    @path = ReturnPathService.error_path(resource_owner, current_user, params[:controller], action)
    @shared_user = ReturnPathService.shared_user(@path)
    @shared_category_names_full = ReturnPathService.shared_category_names(@path)
  end

  def success_path(general_path, shared_path)
    ReturnPathService.success_path(resource_owner, current_user, general_path,
      shared_path)
  end

  def set_contact_shares
    return [] unless @contact.present?
    share_documents = ShareService.shared_documents_by_contact(resource_owner, @contact)
    share_categories = ShareService.shared_categories(resource_owner, nil, @contact).map! { |x| Category.fetch(x.downcase) }
    share_cards = ShareService.shared_cards(resource_owner, nil, @contact)
    @contact_shares = share_documents + share_categories + share_cards
    @contact_documents = DocumentService.contact_documents(resource_owner, @category, @contact.id)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_contact
    @category = "Contact"
    @contact = Contact.for_user(resource_owner).find(params[:id])
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
  
  def contact_emails_rejected
    ContactService.new(:user => resource_owner).contact_all_emails_rejected
  end

  def contact_rejected?
    redirect_to contacts_path if contact_emails_rejected.include? @contact.emailaddress.downcase
  end

  def handle_contact_not_saved(format)
    error_path(:new)
    format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout] }
    format.json { render json: @contact.errors , status: :unprocessable_entity }
  end

  def handle_contact_saved(format)
    UpdateDocumentService.new(:user => resource_owner, :contact => @contact.id, :ret_url => session[:ret_url]).update_document
    format.html { redirect_to success_path(contact_details_path(@contact), contact_details_path(@contact, @shared_user)), flash: { success: 'Contact was successfully created.' } }

    contact_ids = Contact.for_user(resource_owner).sort_by { |s| s.lastname.downcase }.map(&:id)
    contact_position = contact_ids.find_index(@contact.id)
    general_after_id = general_after_id(contact_ids, contact_position)
    after_contact = Contact.find_by(id: general_after_id)

    if after_contact && after_contact.account_owner?(resource_owner)
      shared_after_id = share_contact_after_id(contact_ids, contact_position)
    end

    format.json { render json: @contact.slice(:id, :firstname, :lastname, :relationship, :emailaddress).merge(:position => general_after_id, shared_position: shared_after_id), status: :ok }
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
