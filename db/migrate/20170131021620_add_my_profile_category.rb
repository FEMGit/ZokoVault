class AddMyProfileCategory < ActiveRecord::Migration
  def change
    ["My Profile"].each do |name|
       Category.create! name: name, description: name
     end
  end
end
