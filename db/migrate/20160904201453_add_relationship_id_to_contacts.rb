class AddRelationshipIdToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :relationship_id, :integer
  end
end
