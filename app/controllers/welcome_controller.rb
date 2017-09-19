class WelcomeController < AuthenticatedController
  skip_before_action :authenticate_user!, :complete_setup!, :mfa_verify!, only: [:thank_you, :email_confirmed,
                                                                                 :reset_password_expired]
  helper_method :financial_information_any?, :insurance_vendors_count,
                :tax_year_count, :final_wishes_count, :contacts_count, :button_text,
                :wills_poa_document_count, :wills_poa_any?, :trusts_entities_document_count, :trusts_entities_any?
  before_action :redirect_if_signed_in, only: [:thank_you, :email_confirmed]
  before_action :set_corporate_profile, :set_to_do_modal_popup_view, only: [:index]
  include UserTrafficModule
  include TutorialsHelper
  
  def page_name
    case action_name
      when 'index'
        return "Dashboard"
    end
  end
  
  def onboarding_back
    redirect_result = redirect_to_last_tutorial
    redirect_to new_tutorial_path if redirect_result.blank?
  end

  def index
    user_resource_gatherer = UserResourceGatherer.new(current_user)
    @shares = user_resource_gatherer.shares
    @new_shares = @shares.select { |share| share.created_at > current_user.last_sign_in_at }
    
    @shared_resources = @new_shares.map! do |share|
      if Category === share.shareable
        user_resource_gatherer.category_resources(share)
      else
        share.shareable
      end
    end
    @shared_resources = @shared_resources.compact.flatten
    @shared_users = (@shares.map(&:user).compact + current_user.user_profile.primary_shared_with).uniq

    @new_shares = @new_shares.compact.flatten.uniq(&:user_id)
    
    current_user.update_attribute(:last_sign_in_at, Time.now)
  end
  
  def financial_information_any?
    FinancialProvider.for_user(current_user).any?
  end
  
  def wills_poa_any?
    (wills_poa_document_count > 0) ||
      Will.for_user(current_user).any? ||
      PowerOfAttorneyContact.for_user(current_user).any?
  end
  
  def trusts_entities_any?
    (trusts_entities_document_count > 0) ||
      Trust.for_user(current_user).any? ||
      Entity.for_user(current_user).any?
  end
  
  def wills_poa_document_count
    Document.for_user(current_user).where(:category => Rails.application.config.x.WillsPoaCategory).count
  end
  
  def trusts_entities_document_count
    Document.for_user(current_user).where(:category => Rails.application.config.x.TrustsEntitiesCategory).count
  end
  
  def contacts_count
    Contact.for_user(current_user).reject { |c| c.emailaddress == current_user.email }.count
  end
  
  def insurance_vendors_count
    Vendor.for_user(current_user).count
  end
  
  def tax_year_count
    tax_year_infos = TaxYearInfo.for_user(current_user)
    tax_year_infos.select { |t| t.taxes.present? }.count
  end
  
  def final_wishes_count
    final_wish_infos = FinalWishInfo.for_user(current_user)
    final_wish_infos.select { |t| t.final_wishes.present? }.count
  end
  
  def button_text(any_data)
    return "View" if any_data
    "Start workflow"
  end

  def thank_you; end

  def email_confirmed; end
  
  def reset_password_expired
    @corporate = params[:corporate].eql? 'true'
  end
  
  def do_not_show_popup
    redirect_to root_path and return unless do_not_show_modal_popup_path
    to_do_popup_cancel = ToDoPopupCancel.find_or_initialize_by(user: current_user)
    redirect_to root_path and return unless cancelled_category_name = 
      ToDoPopupModal.popup_name_by_route(path: do_not_show_modal_popup_path)
    to_do_popup_cancel.update(cancelled_popups: (to_do_popup_cancel.cancelled_popups + [cancelled_category_name]).uniq)
    render nothing: true
  end
  
  private
  
  def do_not_show_modal_popup_path
    return nil unless params[:to_do_modal_popup_path]
    params.require(:to_do_modal_popup_path)
  end
  
  def set_corporate_profile
    corporate_admin = current_user.corporate_admin_by_user
    return unless corporate_admin.present?
    @corporate_profile = CorporateAccountProfile.find_by(user: corporate_admin)
  end
  
  def set_to_do_modal_popup_view
    @to_do_modal_popup_view = 
      #if session[:popup_was_shown].nil?
      #  session[:popup_was_shown] = true
        ToDoPopupModal.random_popup_modal(user: current_user)
      #else
      #  nil
      #end
  end
  
  def redirect_if_signed_in
    redirect_to root_path if user_signed_in?
  end
end
