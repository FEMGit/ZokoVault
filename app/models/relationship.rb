class Relationship < ActiveRecord::Base
  self.inheritance_column = nil
  
  scope :personal, -> { where(type: :personal) }
  scope :professional, -> { where(type: :professional) } 
end
