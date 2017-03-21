module UserTrafficModule
  def self.included(base)
    base.before_filter :save_traffic
  end
  
  def save_traffic
    traffic_page_name = page_name
    if traffic_page_name.present? && current_user.present?
      if @shared_user.present?
        traffic_page_name << " (Shared View)"
      end
      @user_traffic_record = UserTraffic.new(:user => current_user,
                                             :ip_address => request.env['REMOTE_ADDR'],
                                             :page_url => request.url,
                                             :page_name => traffic_page_name,
                                             :shared_user_id => @shared_user.try(:id))
      @user_traffic_record.save
    end
  end
  
  def save_traffic_with_params(page_url, page_name)
    if @shared_user.present?
      page_name << " (Shared View)"
    end
    @user_traffic_record = UserTraffic.new(:user => current_user,
                                           :ip_address => request.env['REMOTE_ADDR'],
                                           :page_url => page_url,
                                           :page_name => page_name,
                                           :shared_user_id => @shared_user.try(:id))
    @user_traffic_record.save
  end
end