class ClioController < AuthenticatedController
  include DocumentsHelper
  before_action :redirect_unless_corporate
  before_action :set_clio_service
  
  def authorization
    redirect_to @clio_service.authorization_link(redirect_url: redirect_url)
  end
  
  def index
    session[:clio_access_token] = @clio_service.authorize_with_code(redirect_url: redirect_url, code: params[:code])
    redirect_to clio_sync_corporate_accounts_path and return unless session[:clio_access_token].present?
    set_clio_contacts
    set_clio_contact_documents
  end
  
  private
  
  def set_clio_service
    @clio_service = ClioService.new(access_token: session[:clio_access_token])
  end
  
  def set_clio_contact_documents
    @clio_contact_documents = @clio_service.documents.group_by { |doc| doc["contact"] }
  end
  
  def set_clio_contacts
    @clio_contacts = @clio_service.contacts
    already_used_emails = CorporateAdminAccountUser.select { |x| x.corporate_admin == current_user &&
      x.account_type == CorporateAdminAccountUser.client_type }.map(&:user_account).map(&:email).map(&:downcase)
    return [] if @clio_contacts.blank?
    @clio_contacts.map { |x| x["already_exists"] = (already_used_emails.include? x["primary_email_address"].try(:downcase)) ? true : false }
  end
  
  def redirect_url
   uri = URI.parse(request.url)
   uri.path = clios_path
   uri.query = nil
   uri.to_s
  end
  
  def redirect_uri
    return clios_url
  end
  
  def redirect_unless_corporate
    redirect_to root_path unless current_user.present? && (current_user.corporate_admin || current_user.corporate_employee?)
  end
  
  def corporate_owner
    if current_user.corporate_employee?
      current_user.corporate_admin_by_user
    elsif current_user.corporate_admin
      current_user
    end
  end
end
