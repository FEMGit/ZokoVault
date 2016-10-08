class VaultEntryContact < ActiveRecord::Base
  self.inheritance_column = :_type_disabled

  enum type: [:agent, :executor, :trustee, :succeeded_trustee]

  belongs_to :vault_entry
  belongs_to :contact
end
