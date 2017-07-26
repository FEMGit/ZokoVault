class OnlineAccountService
  def self.update_shares(id, owner)
    return unless OnlineAccount.for_user(owner).find_by(id: id).present? && owner.present?
    Share.where(:shareable_type => 'OnlineAccount', shareable_id: id).update_all(user_id: owner.id)
  end
end
