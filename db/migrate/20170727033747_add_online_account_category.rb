class AddOnlineAccountCategory < ActiveRecord::Migration
  def change
    category_name = Rails.application.config.x.OnlineAccountCategory
    Category.create!(name: category_name, description: category_name)
  end
end
