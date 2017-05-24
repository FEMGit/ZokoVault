class AddSiteCompletedToUsersTable < ActiveRecord::Migration
  def change
    add_column :users, :site_completed, :decimal, :precision => 5, :scale => 2
    
    # Fill table with current users information
    Rails.application.eager_load!
    all_models = ActiveRecord::Base.descendants
    all_models.delete(UserDeathTrap)
    all_models.delete(UserActivity)
    all_models.delete(Category)
    
    User.all.each do |user|
      user_models = all_models.select { |x| x.table_exists? && x.column_names.include?("user_id") }
      completed_count = user_models.select { |x| x.where(:user_id => user.id).any? }.count
      models_with_user_count = user_models.count
      user.update(site_completed: ((completed_count.to_f / models_with_user_count) * 100).round(2))
    end
  end
end
