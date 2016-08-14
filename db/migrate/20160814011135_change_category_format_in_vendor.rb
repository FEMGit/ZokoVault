class ChangeCategoryFormatInVendor < ActiveRecord::Migration
  def self.up
    change_table :vendors do |t|
      t.change :category, :string
      t.change :group, :string
      t.change :name, :string
      t.change :webaddress, :string
      t.change :phone, :string
    end
  end
  def self.down
    change_table :vendors do |t|
      t.change :category, :text
      t.change :group, :text
      t.change :name, :text
      t.change :webaddress, :text
      t.change :phone, :text
    end
  end
end
