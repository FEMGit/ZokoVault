class FixCategoryShares < ActiveRecord::Migration
  def change
    wtl_category = Category.fetch('wills - trusts - legal')
    wills_poa_category = Category.fetch('wills - poa')
    trusts_entities_category = Category.fetch('trusts & entities')
    
    Share.select { |s| s.shareable_type == 'Category' && s.shareable_id == wtl_category.id }.each do |share|
      if Share.select { |s| s.shareable_type == 'Category' && s.shareable_id == wills_poa_category.id && s.contact_id == share.contact_id &&
                            s.user_id == share.user_id }.blank?
        Share.create(share.attributes.except("id").merge(:shareable_id => wills_poa_category.id))
      end
      
      if Share.select { |s| s.shareable_type == 'Category' && s.shareable_id == trusts_entities_category.id && s.contact_id == share.contact_id &&
                            s.user_id == share.user_id }.blank?
        Share.create(share.attributes.except("id").merge(:shareable_id => trusts_entities_category.id))
      end
      
      share.destroy;
    end
  end
end
