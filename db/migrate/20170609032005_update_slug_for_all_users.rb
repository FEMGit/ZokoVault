class UpdateSlugForAllUsers < ActiveRecord::Migration
  def change
    User.find_each(:batch_size => 1000) do |user|
      next unless user.valid?
      user.save!
    end
  end
end
