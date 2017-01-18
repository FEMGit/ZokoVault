module WtlBuildShares
  def build_shares
    share_with_contact_ids.map(&:present?).each do |contact_id|
      shares.build(user_id: user_id, contact_id: contact_id)
    end
  end
end