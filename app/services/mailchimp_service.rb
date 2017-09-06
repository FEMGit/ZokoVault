class MailchimpService
  include StagingHelper
  attr_reader :gibbon
  @@api_slice = 100

  def initialize()
    api_key = ZokuVault::Application.config.mailchimp_secret_token
    @gibbon = Gibbon::Request.new(api_key: api_key)
  end
  
  def unsubscribe_from_all_lists
    check_staging && return
    MailchimpLists::LIST_TYPES.each do |list_type|
      unsubscribe_all(mailchimp_lists(list_type))
    end
  end
  
  def subscribe_to_paid(user)
    subscribe_to(list_type: :paid, user: user)
  end
  
  def subscribe_to_shared(user)
    subscribe_to(list_type: :shared, user: user)
  end
  
  def subscribe_to_trial(user)
    subscribe_to(list_type: :trial, user: user)
  end
  
  def subscribe_to_corporate(user)
    subscribe_to(list_type: :corporate, user: user)
  end
  
  def add_to_subscription_based_list(user)
    unless user.current_user_subscription.present?
      subscribe_to_shared(user)
      return
    end

    if user.current_user_subscription.active_trial?
      subscribe_to_trial(user)
    elsif user.current_user_subscription.active_full?
      subscribe_to_paid(user)
    else
      subscribe_to_shared(user)
    end
  end
  
  def unsubscribe_from_all_except(except:, user:)
    MailchimpLists::LIST_TYPES.reject { |type| Array.wrap(except).include? type }.each do |list_type|
      unsubscribe_from(list_type: list_type, user: user)
    end
  end
  
  private
    
  def check_staging
    return true if develop_staging?
    false
  end
  
  def unsubscribe_all(list_name)
    list_id = list_id_by_name(list_name)
    member_emails = members_emails(list_id)
    
    member_emails.each do |email|
      member_id = member_id_by_email(list_id, email)
      next unless list_id.present? && member_id.present?
      @gibbon.lists(list_id).members(member_id).delete
    end
  end
  
  def unsubscribe_from(list_type:, user:)
    check_staging && return
    return unless MailchimpLists::LIST_TYPES.include? list_type
    unsubscribe(mailchimp_lists(list_type), user)
  end
  
  def unsubscribe(list_name, user)
    list_id = list_id_by_name(list_name)
    member_id = member_id_by_email(list_id, user.email)
    return unless list_id.present? && member_id.present?
    @gibbon.lists(list_id).members(member_id).delete
  end
  
  def subscribe_to(list_type:, user:)
    check_staging && return
    subscribe(mailchimp_lists(list_type), user)
    unsubscribe_from_all_except(except: list_type, user: user)
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
            FNAME: user.try(:first_name) || "",
            LNAME: user.try(:last_name) || ""
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
    
  def lists
    offset = 0
    mailchimp_lists = []
    until (list_slice = @gibbon.lists
                                  .retrieve(params: {"count": @@api_slice.to_s, "offset": offset.to_s})
                                  .body["lists"]).blank? do
      mailchimp_lists << list_slice
      offset += @@api_slice
    end
    mailchimp_lists.flatten
  end
  
  def list(list_id)
    @gibbon.lists(list_id).retrieve
  end
  
  def list_id_by_name(name)
    list_name = lists.detect { |l| l["name"] == name }
    return nil unless list_name
    list_name["id"]
  end

  def mailchimp_lists(type)
    if ENV['STAGING_TYPE'].eql? 'production'
      MailchimpLists::PRODUCTION[type]
    elsif ENV['STAGING_TYPE'].eql? 'beta'
      MailchimpLists::BETA[type]
    else
      nil
    end
  end
end
