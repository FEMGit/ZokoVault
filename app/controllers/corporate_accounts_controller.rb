class CorporateAccountsController < AuthenticatedController
  before_action :redirect_unless_corporate_admin
  
  def index; end
  
  private
  
  def redirect_unless_corporate_admin
    redirect_to root_path unless current_user.present? && current_user.corporate_admin
  end
end
