module FinalWishesHelper
  def final_wish_details(group)
    final_wish = @final_wishes.where(:group => group).first
    if final_wish
      "#{final_wishes_path}/#{final_wish.id}"
    else
      ""
    end
  end

  def final_wish_add_details(group)
    final_wish = @final_wishes.where(:group => group).first
    if final_wish
      "#{final_wishes_path}/#{final_wish.id}/edit"
    else
      new_final_wish_path(:group => group)
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
    final_wishes.any? { |fw| fw.group == group }
  end
  
  def final_wish_present?(final_wish)
    final_wish.primary_contact.present? || final_wish.notes.present? || final_wish.share_with_contacts.present?
  end
end
