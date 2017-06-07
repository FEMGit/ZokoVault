class TutorialSelection < ActiveRecord::Migration
  def change
    create_table :tutorial_selections do |t|
      t.references :user, index: true, foreign_key: true
      t.jsonb :tutorial_paths
      t.integer :last_tutorial_index

      t.timestamps null: false
    end
  end
end
