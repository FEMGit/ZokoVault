class WelcomeController < AuthenticatedController
  skip_before_action :authenticate_user!, :complete_setup!, :mfa_verify!, only: [:thank_you, :email_confirmed]
  helper_method :financial_information_any?, :estate_planning_document_count, :insurance_vendors_count,
                :tax_year_count, :final_wishes_count, :contacts_count, :button_text

  def index; 
    user_resource_gatherer = UserResourceGatherer.new(current_user)
    @shares = user_resource_gatherer.shares
    @new_shares = @shares.select { |share| share.created_at > current_user.last_sign_in_at}
    
    @shared_resources = @new_shares.map! do |share|
      if Category === share.shareable
        user_resource_gatherer.category_resources(share)
      else
        share.shareable
      end
    end
    @shared_resources.compact.flatten!
    @shared_users = @shares.select(&:user).compact.uniq
    
    current_user.update_attribute(:last_sign_in_at, Time.now)
  end
  
  def financial_information_any?
    FinancialProvider.for_user(current_user).any?
  end
  
  def estate_planning_document_count
    Document.for_user(current_user).where(:category => Rails.application.config.x.WtlCategory).count
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
  
end
