class CorporateEmployeeProfile < ActiveRecord::Base
  belongs_to :corporate_employee, :class_name => 'User'
  
  validate :validate_relationship
  
  private
  
  def validate_relationship
    if !Contact::CONTACT_TYPES[contact_type].include?(relationship)
      self.errors[:relationship] << "is invalid for contact_type #{contact_type}"
    end
  end
end
