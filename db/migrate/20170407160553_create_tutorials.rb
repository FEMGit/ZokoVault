class CreateTutorials < ActiveRecord::Migration
  def change
    create_table :tutorials do |t|
      t.string :name
      t.string :content

      t.timestamps null: false
    end
    ['Tutorial 1', 'Tutorial 2', 'Tutorial 3', 'Tutorial 4'].each do |tutorial|
      Tutorial.create(name: tutorial, content: "Content of #{tutorial}")
    end
  end
end
