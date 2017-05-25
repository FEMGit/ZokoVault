class AccountTrafficsController < AuthenticatedController
  helper_method :user_link, :resource_link

  def page_name
    case action_name
      when 'index'
        "Account Traffic"
    end
  end
  
  def index
    respond_to do |format|
      format.html
      format.json { render json: UserTrafficDatatable.new(view_context) }
    end
  end
  
  private

  def user_link(traffic_info)
    return my_profile_path if traffic_info.user == current_user
    contact = Contact.for_user(current_user).detect do |c|
      c.emailaddress.downcase.eql? traffic_info.user.email.downcase
    end
    ### HARDCODED RESPONSE BECAUSE I CAN'T FIND nil CONTACT ON MY LOCALHOST
    ### CHECK IT ON PRODUCTION IN HOMER's ACCOUNT...
    return "#" if contact.blank?
    contact_path(contact)
  end

  def resource_link(traffic_info)
    return root_path if traffic_info.page_url.eql? root_url
    begin
      recognized_path = Rails.application.routes.recognize_path(traffic_info.page_url)
    rescue
      return ""
    end
    
    return "" if recognized_path[:action] == "catch_404"
    return traffic_info.page_url if traffic_info.user == current_user
    begin
      return url_for(recognized_path.except(:shared_user_id)) unless shared_to_general_categories_path(recognized_path)
      shared_to_general_categories_path(recognized_path)
    rescue
      ""
    end
  end
  
  def shared_to_general_categories_path(page_path)
    if page_path[:controller].eql? 'shared_view'
      case page_path[:action]
        when 'insurance'
          return insurance_path
        when 'taxes'
          return taxes_path
        when 'final_wishes'
          return final_wishes_path
        when 'financial_information'
          return financial_information_path
        when 'trusts_entities'
          return trusts_entities_path
        when 'wills_powers_of_attorney'
          return wills_powers_of_attorney_path
        when 'dashboard'
          return root_path
      end
    end
    return nil
  end
end
