class FinalWishService
  def self.fill_wishes(wishes, wish_info, current_user_id)
    wishes.values.each do |wish|
      if wish[:id].present?
        wish_info.final_wishes.update(wish[:id], wish)
      else
        wish_info.final_wishes << FinalWish.new(wish.merge(:user_id => current_user_id))
      end
    end
  end
  
    
  def self.get_wish_info(group, user)
    FinalWishInfo.for_user(user).where(:group => group).first
  end
  
  def self.get_wish_group_value_by_id(groups, id)
    groups.detect { |group| group["label"] == FinalWishInfo.friendly.find_or_return_nil(id).try(:group) }
  end
  
  def self.get_wish_group_value_by_name(groups, name)
    groups.detect { |group| group["label"] == name }
  end
  
  def self.update_shares(final_wish_info, previous_share_with_contact_ids, user)
    share_contact_ids = final_wish_info.final_wishes.map(&:share_with_contact_ids).uniq
    return unless previous_share_with_contact_ids.present?
    ShareInheritanceService.update_document_shares(user, share_contact_ids, previous_share_with_contact_ids.flatten,
                                                   Rails.application.config.x.FinalWishesCategory, final_wish_info.group)
  end
end
