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
    groups.detect { |group| group["label"] == FinalWishInfo.find_by(:id => id).group }
  end
  
  def self.get_wish_group_value_by_name(groups, name)
    groups.detect { |group| group["label"] == name }
  end
  
  def self.update_shares(final_wish_info, share_with_contact_ids, user_id)
    final_wish_info.final_wishes.each do |final_wish|
      final_wish.shares.clear
      share_with_contact_ids.each do |contact_id|
        final_wish.shares << Share.create(contact_id: contact_id, user_id: user_id)
      end
    end
  end
end
