class DocumentsController < AuthenticatedController
  include SharedViewModule
  include DocumentsHelper
  include BackPathHelper
  include SanitizeModule
  include DateHelper
  before_action :set_header_info_blank_layout, only: [:new]
  before_action :set_document, only: [:show, :edit, :update, :destroy, :download, :preview]
  before_action :set_contacts, only: [:new, :create, :edit, :update]
  before_action :set_viewable_contacts, only: [:update, :edit]
  before_action :prepare_document_params, only: [:create, :update]
  before_action :set_dropdown_options, only: [:new, :edit]
  before_action :prepare_shares, only: [:update]
  before_action :set_document_content_type, only: [:show, :preview]
 
  # Breadcrumbs navigation
  before_action :set_previous_crumbs, only: [:new, :edit, :show, :preview, :download]
  before_action :set_index_crumbs, only: [:index]
  before_action :set_add_crumbs, :set_first_run, only: [:new, :create]
  before_action :set_edit_crumbs, only: [:edit, :update]
  before_action :set_show_crumbs, only: [:preview]
  layout :resolve_layout, only: [:new, :edit, :index, :preview]
  include BreadcrumbsCacheModule
  include UserTrafficModule

  def page_name
    case action_name
      when 'index'
        return "Documents"
      when 'new'
        return "Add Document"
      when 'edit'
        document = Document.for_user(resource_owner).find_by(uuid: params[:uuid])
        return "#{document.name} - Edit"
      when 'preview'
        document = Document.for_user(resource_owner).find_by(uuid: params[:uuid])
        return "#{document.name} - Preview"
      when 'download'
        document = Document.for_user(resource_owner).find_by(uuid: params[:uuid])
        return "#{document.name} - Download"
    end
  end

  def set_previous_crumbs
    return unless back_path.present?
    @breadcrumbs = BreadcrumbsCacheModule.cache_breadcrumbs_pop(current_user, @shared_user)
    BreadcrumbsCacheModule.cache_temp_breadcrumbs_write(@breadcrumbs.present? ? @breadcrumbs.dup : [], resource_owner)
  end

  def set_index_crumbs
    add_breadcrumb "Documents", documents_path if general_view?
  end

  def set_add_crumbs
    add_breadcrumb "Add Document", new_documents_path(@shared_user)
  end

  def set_edit_crumbs
    add_breadcrumb "Edit Document", edit_documents_path(@document, @shared_user)
  end

  def set_show_crumbs
    add_breadcrumb "Document Preview", preview_document_path(@document, @shared_user)
  end

  @after_new_user_created = ""

  def index
    @documents = policy_scope(Document).each { |d| authorize d }
    @category = Category.fetch(Rails.application.config.x.DocumentsCategory.downcase)
    @contacts_with_access = current_user.shares.categories.select { |share| share.shareable.eql? @category }.map(&:contact) 
    session[:ret_url] = "/documents"
  end

  def show
    authorize @document
    if Document.previewed?(@document_content_type) 
      redirect_to preview_document_path(@document, @shared_user) and return
    else
      redirect_to download_document_path(@document, @shared_user) and return
    end
  end
  
  def download
    authorize @document
    document_key = @document.url
    data = open(download_file(document_key))
    send_data data.read, type: data.metas["content-type"], filename: document_key.split('_').last
  end
  
  def preview
    authorize @document
    @image = Document.image?(@document_content_type)
    @pdf = Document.pdf?(@document_content_type)
  end

  def new
    @document = Document.new(base_params.slice(:category, :group, :vendor_id, :financial_information_id, :card_document_id).merge(user: resource_owner))

    authorize @document

    @cards = card_values(@document.category)
    @card_names = card_names(@document.category)
    set_viewable_contacts
  end

  def edit
    authorize @document
    session[:ret_url] = get_return_url_path
    @shares = @document.shares
    @card_names = card_names(@document.category).uniq
    @cards = card_values(@document.category).uniq
    set_viewable_contacts
  end

  def create
    options = document_params.merge(user: resource_owner)
    @document = Document.new(options)

    authorize @document

    saved = validate_params && @document.save &&
                               @document.reload &&
                               @document.update(document_changes(:create))

    respond_to do |format|
      if saved
        save_traffic_with_params(document_path(@document), 'Uploaded New Document')
        handle_document_saved(format)
      else
        handle_document_not_saved(format)
      end
    end
  end

  def update
    authorize @document
    respond_to do |format|
      set_document_update_date_to_now(@document)
      if validate_params && @document.update(document_changes(:update))
        save_traffic_with_params(document_path(@document), 'Updated Document')
        BreadcrumbsCacheModule.cache_temp_breadcrumbs_delete
        if return_url?
          format.html { redirect_to session[:ret_url], flash: { success: 'Document was successfully updated.' } }
        else
          format.html { redirect_to documents_path, flash: { success: 'Document was successfully updated.' } }
        end
        format.json { render :show, status: :ok, location: @document }
      else
        handle_document_not_updated(format)
      end
    end
  end

  def destroy
    authorize @document

    @document.destroy
    S3Service.delete_from_storage(@document.url)
    redirect_page = session[:ret_url] || documents_path
    respond_to do |format|
      format.html { redirect_to redirect_page, notice: 'Document was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def mass_document_upload
    return unless mass_upload_files_params.present?
    files = JSON.parse mass_upload_files_params
    file_params = files.collect { |x| [name: x["filename"], url: x["key"], user: resource_owner, uuid: SecureRandom.uuid] }.flatten
    mass_upload_add_shares_if_shared_view(file_params)
    if documents = Document.create(file_params)
      render :json => { :success => true, documents: documents.map{ |d| d.as_json.merge(additional_json_params(d)) }, message: "Documents were successfully created." }, :status => 200
    else
      render :json => { :error => "Error occured, please try again later." }, :status => 500
    end
  end
  
  def mass_upload_files_params
    return nil unless params[:mass_upload_files].present?
    params.require(:mass_upload_files)
  end

  def get_drop_down_options
    render :json => card_values(base_params[:category]).flatten
  end

  def get_card_names
    render :json => card_names(base_params[:category]).flatten
  end
  
  def document_category_share_contacts
    render :json => ShareService.category_contacts_shared_with(resource_owner, base_params[:category])
  end
  
  def document_subcategory_share_contacts
    render :json => ShareService.subcategory_contacts_shared_with(resource_owner, base_params[:category], base_params[:subcategory])
  end

  private
  
  def mass_upload_add_shares_if_shared_view(file_params)
    if current_user != resource_owner
      contact = Contact.for_user(resource_owner).where("emailaddress ILIKE ?", current_user.email).first
      document_access_shared = resource_owner.shares.any? { |sh| sh.shareable == Category.fetch(Rails.application.config.x.DocumentsCategory.downcase) && sh.contact == contact }
      if document_access_shared == true
        file_params.each { |f| f[:contact_ids] = Array.wrap(contact.id) }
      end
    end
  end
  
  def set_document_content_type
    s3_object = S3Service.get_object_by_key(@document.url)
    return nil unless s3_object.exists?
    @document_content_type = s3_object.content_type
  end

  def validate_params
    category_name = document_params[:category]
    card_values = card_values(category_name)
    card_names = card_names(category_name)
    permitted_names =
      if category_name == Rails.application.config.x.ContactCategory
        (card_values.flatten + card_names.flatten).map { |x| x[:id] }.map(&:to_s)
      else
        (card_values.flatten + card_names.flatten).map { |x| x[:name] }
      end
    permitted_names.include? document_params[:group]
  end

  def set_dropdown_options
    @category_dropdown_options =
    if base_params[:category].present?
      [base_params[:category]]
    else
     (resource_owner != current_user) ? @shared_category_names_full.prepend('Select...') : CategoryDropdownOptions::CATEGORIES
    end
  end

  def card_values(category)
    service = DocumentService.new(:category => category)
    service.get_card_values(resource_owner, current_user)
  end

  def card_names(category)
    service = DocumentService.new(:category => category)
    service.get_card_names(resource_owner, current_user)
  end

  def shared_user_params
    params.permit(:shared_user_id)
  end

  def resource_owner
    if shared_user_params[:shared_user_id].present?
      User.find_by(id: params[:shared_user_id])
    else
      @document.present? ? @document.user : current_user
    end
  end

  def set_contacts
    contact_service = ContactService.new(:user => resource_owner)
    @contacts = contact_service.contacts
    @contacts_shareable = contact_service.contacts_shareable
  end

  def set_viewable_contacts
    share_contact_ids = document_shares(@document).map(&:contact_id).select { |c| Contact.exists? id: c }
    @document.contact_ids |= share_contact_ids
  end

  def set_document
    @document = Document.find_by!(uuid: params[:uuid])
    @cards = card_values(@document.category)
  end

  def download_params
    params.permit(:uuid)
  end

  def base_params
    params.permit(:group, :category, :vendor_id, :financial_information_id, :card_document_id, :subcategory)
  end

  def document_changes(type)
    base =
      case type
      when :create then document_params
      when :update then document_update_params
      else raise ArgumentError, "unknown document_changes type: #{mode.inspect}"
      end
    merges = { user_id: resource_owner.id }
    shares = document_share_attributes
    merges[:shares_attributes] = shares unless shares.nil?
    base.merge(merges)
  end

  def document_share_attributes
    if @shared_user.nil?
      @document.contact_ids = params[:document][:contact_ids]
      share_service = ShareService.new(user_id: resource_owner.id, contact_ids: params[:document][:contact_ids])
      share = share_service.fill_document_share
      # Clear document shares before updating current document
      share_service.clear_shares(@document)

      viewable_shares = document_shares(@document).map(&:contact_id).map(&:to_s)
      share.reject! { |k, v| viewable_shares.include? v["contact_id"] }

      share
    end
  end

  def editable_document_attrs
    [ :name, :description, :category, :contact_ids, :group,
      :financial_information_id, :card_document_id, :vendor_id ]
  end

  def document_params
    params.require(:document).permit(
      *editable_document_attrs, :url, :user_id, shares_attributes: [:user_id, :contact_id])
  end

  def document_update_params
    params.require(:document).permit(
      *editable_document_attrs, shares_attributes: [:user_id, :contact_id])
  end

  def return_url?
    return if session[:ret_url].blank?

    %w[/contacts /insurance /documents].any? {|ret| session[:ret_url].start_with?(ret)} || :return_after_new_user
  end

  def save_return_url_path(document_id_to_change)
    @after_new_user_created = session[:ret_url]
    session[:ret_url] = "/documents/" + document_id_to_change.to_s + "/edit"
  end

  def get_return_url_path
    url = Rails.cache.read('after_new_user_created') || session[:ret_url]
    Rails.cache.delete('after_new_user_created')
    url
  end

  def document_clean_from_create_new_user_id
    params[:document][:shares_attributes].delete_if{|k, v| v[:contact_id] == new_contact_path}
  end

  def set_document_update_date_to_now(document)
    document.updated_at = Time.now.utc
  end

  def prepare_shares
    if DocumentService.category_or_group_changed?(@document, document_params[:category], base_params[:group],
                                                  document_params[:financial_information_id], document_params[:vendor_id], document_params[:card_document_id])
      params[:document][:contact_ids] = [];
    end
  end

  def prepare_document_params
    if DocumentService.update_group?(base_params[:group], document_params[:category])
      params[:document][:vendor_id] = nil
      params[:document][:financial_information_id] = nil
      params[:document][:card_document_id] = nil
    else
      params[:group] = DocumentService.empty_value
    end
  end

  def handle_document_saved(format)
    #TODO: dynamic route builder for categories
    BreadcrumbsCacheModule.cache_temp_breadcrumbs_delete
    if return_url?
      format.html { redirect_to session[:ret_url], flash: { success: 'Document was successfully created.' } }
    else
      format.html { redirect_to documents_path, flash: { success: 'Document was successfully created.' } }
    end
    format.json { render json: @document.as_json.merge(additional_json_params(@document)), status: :created }
  end

  def additional_json_params(document)
    additional_json_params = Hash.new
    additional_json_params["primary_tag"] = document.category.blank? ? "Document" : document.category
    secondary_tag_name = secondary_tag(document)
    if secondary_tag_name.present?
      additional_json_params["secondary_tag"] = secondary_tag_name
    end
    additional_json_params["document_path"] = document_path(document)
    additional_json_params["modified_date"] = date_format(document.updated_at)
    additional_json_params["share_contacts"] = render_to_string partial: 'layouts/avatar_circle_collection', locals: { contacts: document.contacts }

    additional_json_params
  end

  def handle_document_not_saved(format)
    breadcrumbs_error_handled
    set_first_run
    error_documents_initialize
    format.html { render :new, :layout => resolve_layout }
    format.json { render json: @document.errors, status: :unprocessable_entity }
  end

  def handle_document_not_updated(format)
    breadcrumbs_error_handled
    error_documents_initialize
    format.html { render :edit, :layout => set_layout }
    format.json { render json: @document.errors, status: :unprocessable_entity }
  end

  def error_documents_initialize
    @cards = card_values(@document.category)
    @card_names = card_names(@document.category)
    set_dropdown_options
  end

  def breadcrumbs_error_handled
    temp_crumbs = BreadcrumbsCacheModule.cache_temp_breadcrumbs_pop(current_user, @shared_user)
    @breadcrumbs.prepend(temp_crumbs).flatten! if temp_crumbs.present?
  end

  def first_run?
    params[:first_run].eql? 'true' || @first_run
  end

  def set_first_run
    @first_run = first_run?
  end

  def resolve_layout
    if first_run?
      set_header_info_blank_layout
      'blank_layout'
    else
      set_layout
    end
  end

  def set_header_info_blank_layout
    @header_information = true
  end
end
