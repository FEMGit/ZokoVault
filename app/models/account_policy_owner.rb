class AccountPolicyOwner < ActiveRecord::Base
  belongs_to :contact
  belongs_to :card_document
  
  def name
    (Contact.find_by(id: contact_id) || CardDocument.find_by(id: card_document_id)).try(:name)
  end
  
  def emailaddress
    return unless contact_id.present?
    Contact.find_by(id: contact_id).emailaddress
  end
  
  def phone
    return unless contact_id.present?
    Contact.find_by(id: contact_id).phone
  end
end
