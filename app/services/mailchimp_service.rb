class MailchimpService
  attr_reader :gibbon
  @@api_slice = 100

  def initialize()
    api_key = ZokuVault::Application.config.mailchimp_secret_token
    @gibbon = Gibbon::Request.new(api_key: api_key)
  end
  
  def lists
    @gibbon.lists.retrieve.body["lists"]
  end
  
  def list(list_id)
    @gibbon.lists(list_id).retrieve
  end
  
  def subscribe_to_paid(user)
    subscribe(mailchimp_lists[:paid], user)
    unsubscribe_from_shared(user)
    unsubscribe_from_trial(user)
  end
  
  def subscribe_to_shared(user)
    subscribe(mailchimp_lists[:shared], user)
    unsubscribe_from_paid(user)
    unsubscribe_from_trial(user)
  end
  
  def subscribe_to_trial(user)
    subscribe(mailchimp_lists[:trial], user)
    unsubscribe_from_shared(user)
    unsubscribe_from_paid(user)
  end

  private
  
  def unsubscribe_from_paid(user)
    unsubscribe(mailchimp_lists[:paid], user)
  end
  
  def unsubscribe_from_shared(user)
    unsubscribe(mailchimp_lists[:shared], user)
  end
  
  def unsubscribe_from_trial(user)
    unsubscribe(mailchimp_lists[:trial], user)
  end
  
  def unsubscribe(list_name, user)
    list_id = list_id_by_name(list_name)
    member_id = member_id_by_email(list_id, user.email)
    return unless list_id.present? && member_id.present?
    @gibbon.lists(list_id).members(member_id).delete
  end
  
  def subscribe(list_name, user)
    list_id = list_id_by_name(list_name)
    return unless list_id.present? &&
                  (!members_emails(list_id).include? user.email)
    begin
      @gibbon.lists(list_id).members.create(
        body: {
          email_address: user.email,
          status: "subscribed",
          merge_fields: {
            FNAME: user.first_name,
            LNAME: user.last_name
          }
        }
      )
    rescue Exception => exception
      requested_page = 'mailchimp service'
      error = exception.message
      user_death_trap = UserDeathTrap.new(user: user, page_terminated_on: requested_page, error_message: error)
      user_death_trap.save
    end
  end
  
  def member_id_by_email(list_id, email)
    members_list = members(list_id)
    return if members_list.blank?
    member_email = members_list.detect { |m| m["email_address"] == email }
    return nil unless member_email
    member_email["id"]
  end
  
  def members_emails(list_id)
    emails = members(list_id).map { |x| x["email_address"] }
  end
    
  def members(list_id)
    offset = 0
    members_list = []
    until (members_slice = @gibbon.lists(list_id).members
                                               .retrieve(params: {"fields": "members.email_address,members.id", "count": @@api_slice.to_s, "offset": offset.to_s})
                                               .body["members"]).blank? do
      members_list << members_slice
      offset += @@api_slice
    end
    members_list.flatten
  end
  
  def list_id_by_name(name)
    list_name = lists.detect { |l| l["name"] == name }
    return nil unless list_name
    list_name["id"]
  end

  def mailchimp_lists
    {paid: 'Paid Subscriber', shared: 'Shared With User',
     trial: 'Free Trial Users'}
  end
end
