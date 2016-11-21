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
end
