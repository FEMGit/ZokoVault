module FinalWishesHelper
  def final_wish_details(group)
    final_wish = @final_wishes.detect { |fw| fw.group == group }
    return unless final_wish
    return final_wish_path(final_wish) unless @shared_user
    final_wish_shared_view_path(id: final_wish.id)
  end

  def final_wish_add_details(group)
    final_wish = @final_wishes.detect { |fw| fw.group == group }
    if final_wish && final_wish.final_wishes.any?
      return final_wish_path(final_wish) unless @shared_user
      final_wish_shared_view_path(id: final_wish.id)
    else
      return new_final_wish_path(:group => group) unless @shared_user
      new_final_wish_shared_view_path(:group => group)
    end
  end
  
  def wish_by_group(group)
    final_wish = @final_wishes.where(:group => group).first
    final_wish.final_wishes.first
  end
  
  def final_wish_info(group)
    @final_wishes.where(:group => group).first
  end

  def final_wish_exists?(final_wishes, group)
    final_wish_info = final_wishes.detect { |x| x.group == group }
    final_wish_info && final_wish_info.final_wishes.any?
  end
  
  def final_wish_present?(final_wish)
    final_wish.primary_contact.present? || final_wish.notes.present? || category_subcategory_shares(final_wish, final_wish.user)
  end
end
