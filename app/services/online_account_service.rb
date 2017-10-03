class OnlineAccountService
  def self.create_shares(online_account_id:, owner:, share_with_contact_ids:)
    online_account = OnlineAccount.for_user(owner).find_by(id: online_account_id)
    return if online_account.blank? || owner.blank?
    share_with_contact_ids.select(&:present?).each do |contact_id|
      online_account.shares.build(user_id: owner.id, contact_id: contact_id)
    end
    online_account.update_attributes(share_with_contact_ids: share_with_contact_ids)
  end
  
  def self.update_shares(online_account_id:, owner:)
    return if owner.blank?
    return if OnlineAccount.for_user(owner).find_by(id: online_account_id).blank?
    Share.where(:shareable_type => 'OnlineAccount', shareable_id: online_account_id).update_all(user_id: owner.id)
  end
end