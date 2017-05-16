class AddTrustTutorial < ActiveRecord::Migration
  def change
    Tutorial.create(name: 'Trust', number_of_pages: 1)
  end
end
