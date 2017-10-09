class FinalWishInfoPolicy < CategorySharePolicy
  def owner_shared_record_with_user?
    shares = policy_share
    return false unless shares
    final_wish_shared_ids = shares.select { |sh| sh.shareable.is_a? FinalWish }.map(&:shareable_id)
    (record.final_wishes.map(&:id) & final_wish_shared_ids).any?
  end
end
