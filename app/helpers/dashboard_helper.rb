module DashboardHelper
  def additional_card_class_and_id_by_category(is_category_empty, category_name)
    additional_class = 
      if is_category_empty && !to_do_category_dismissed?(category_name)
        " d-none "
      else
        ""
      end
    card_id = category_name.parameterize('_')
    [additional_class, card_id]
  end
end
