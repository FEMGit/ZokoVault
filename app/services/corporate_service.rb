class CorporateService
  def self.remove_client_from_admin(client:, admin:)
    return unless admin.corporate_admin && client.corporate_user_by_admin?(admin)
    remove_client_shares(client: client)
    CorporateAdminAccountUser.where(corporate_admin: admin, user_account: client).delete_all
    CorporateEmployeeAccountUser.where(user_account: client).delete_all
    StripeService.cancel_subscription(user: client) if client.current_user_subscription.corporate?(corporate_client: client)
  end
  
  private
  
  def self.remove_client_shares(client:)
    return unless client.present?
    Share.where(user: client).each do |client_share|
      next unless manager = User.where("email ILIKE ?", client_share.contact.emailaddress).first
      client_share.destroy if client.corporate_user_by_employee?(manager) || client.corporate_user_by_admin?(manager)
    end
  end
end
