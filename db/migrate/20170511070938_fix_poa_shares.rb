class FixPoaShares < ActiveRecord::Migration
  def change
    poa_shares = Share.select { |s| s.shareable_type == 'PowerOfAttorney' }
    poa_shares.each do |poa_share|
      poa_contact_id = PowerOfAttorney.find(poa_share.shareable_id).power_of_attorney_id
      next if PowerOfAttorneyContact.find_by(id: poa_contact_id).share_with_contact_ids.include? poa_share.contact_id
      Share.create(shareable_id: poa_contact_id, shareable_type: 'PowerOfAttorneyContact', user: poa_share.user, contact_id: poa_share.contact_id)
    end
  end
end
