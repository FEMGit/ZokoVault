class UpdateWtlCategoryValues < ActiveRecord::Migration
  def change
    # Update Categories of existing POA, Will and Trust cards
    will_poa_category = Category.fetch('wills - poa')
    trusts_entities_category = Category.fetch('trusts & entities')
    PowerOfAttorney.update_all(category_id: will_poa_category.id)
    PowerOfAttorneyContact.update_all(category_id: will_poa_category.id)
    Will.update_all(category_id: will_poa_category.id)
    Trust.update_all(category_id: trusts_entities_category.id)
    
    # Seed CardDocuments table with all existing Will, POA and Trust cards
    wills = Will.all
    wills.each do |will|
      next if User.find_by(id: will.user_id).nil?
      CardDocument.create(card_id: will.id, user_id: will.user_id, object_type: will.class, category_id: will_poa_category.id)
    end
    
    entities = Entity.all
    entities.each do |entity|
      next if User.find_by(id: entity.user_id).nil?
      CardDocument.create(card_id: entity.id, user_id: entity.user_id, object_type: entity.class, category_id: trusts_entities_category.id)
    end
    
    trusts = Trust.all
    trusts.each do |trust|
      next if User.find_by(id: trust.user_id).nil?
      CardDocument.create(card_id: trust.id, user_id: trust.user_id, object_type: trust.class, category_id: trusts_entities_category.id)
    end
    
    power_of_attorney_contacts = PowerOfAttorneyContact.all
    power_of_attorney_contacts.each do |poa_contact|
      next if User.find_by(id: poa_contact.user_id).nil?
      CardDocument.create(card_id: poa_contact.id, user_id: poa_contact.user_id, object_type: poa_contact.class, category_id: will_poa_category.id)
    end
    
    # Duplicate old document to new categories
    wtl_documents = Document.where(category: 'Wills - Trusts - Legal', group: 'Select...')
    wtl_documents.each do |document|
      Document.create(document.attributes.except("id").merge("category"=>"Wills - POA"))
    end
    
    will_documents = Document.where(category: 'Wills - Trusts - Legal', group: 'Will')
    will_documents.each do |document|
      Document.create(document.attributes.except("id").merge("category"=>"Wills - POA", "group"=>"Select..."))
    end
    
    trust_documents = Document.where(category: 'Wills - Trusts - Legal', group: 'Trust')
    trust_documents.each do |document|
      Document.create(document.attributes.except("id").merge("category"=>"Trusts & Entities", "group"=>"Select..."))
    end
    
    poa_documents = Document.where(category: 'Wills - Trusts - Legal', group: 'Legal')
    poa_documents.each do |document|
      Document.create(document.attributes.except("id").merge("category"=>"Wills - POA", "group"=>"Select..."))
    end
  end
end
