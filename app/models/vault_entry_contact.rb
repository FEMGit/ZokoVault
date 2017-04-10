class VaultEntryContact < ActiveRecord::Base
  self.inheritance_column = :_type_disabled

  enum type: [:agent, :executor, :trustee, :successor_trustee, :power_of_attorney, :partner]

  belongs_to :contact
end
