class CreateWordsTable < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.string :word, :null => false
    end
  end
end
