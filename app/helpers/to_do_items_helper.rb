module ToDoItemsHelper
  def to_do_category_dismissed?(user = current_user, category_name)
    ToDoCancel.find_or_initialize_by(user: user).cancelled_categories.include? category_name
  end
end
