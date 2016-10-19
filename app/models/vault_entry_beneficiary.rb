class VaultEntryBeneficiary < ActiveRecord::Base
  self.inheritance_column = :_type_disabled

  enum type: [:primary, :secondary]

  belongs_to :contact
  belongs_to :will
end
