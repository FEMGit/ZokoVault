class VaultEntryContact < ActiveRecord::Base
  self.inheritance_column = :_type_disabled

  enum type: [:agent, :executor]

  belongs_to :vault_entry
  belongs_to :contact
end
