module AccountPolicyOwnerHelper
  def owner_ids_transform(account_policy_ids)
    AccountPolicyOwner.where(id: account_policy_ids).collect { |ac_ow| ac_ow.contact_id.present? ? ac_ow.contact_id.to_s + '_contact' : ac_ow.card_document_id.to_s + '_owner' }
  end
end
