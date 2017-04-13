class CreateTutorials < ActiveRecord::Migration
  def change
    create_table :tutorials do |t|
      t.string :name
      t.string :content

      t.timestamps null: false
    end
    ['Insurance', 'Home', 'Tutorial 3', 'Tutorial 4'].each do |tutorial|
      Tutorial.create(name: tutorial, content: "Content of #{tutorial}")
    end
  end
end
