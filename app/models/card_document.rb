class CardDocument < ActiveRecord::Base
  scope :for_user, ->(user) { where(user_id: user.id) }
  
  belongs_to :category
  
  has_many :documents, class_name: "Document", foreign_key: :card_document_id, dependent: :nullify
  
  def name
    object = (Object.const_get self.object_type).find(self.card_id)
    object.try(:name) || object.try(:title) || "PoA for #{object.contact.try(:name)}"
  end
  
  def share_with_contacts
    object = (Object.const_get self.object_type).find(self.card_id)
    object.share_with_contacts
  end
  
  def share_with_contact_ids
    object = (Object.const_get self.object_type).find(self.card_id)
    object.share_with_contact_ids
  end
  
  def self.will(id)
    CardDocument.find_by(object_type: 'Will', card_id: id)
  end
  
  def self.power_of_attorney(id)
    CardDocument.find_by(object_type: 'PowerOfAttorneyContact', card_id: id)
  end
  
  def self.trust(id)
    CardDocument.find_by(object_type: 'Trust', card_id: id)
  end
  
  def self.entity(id)
    CardDocument.find_by(object_type: 'Entity', card_id: id)
  end
end