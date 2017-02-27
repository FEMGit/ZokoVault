class LifeAndDisability < Vendor

  has_many :policy, 
    class_name: "LifeAndDisabilityPolicy",
    foreign_key: :vendor_id
  
  accepts_nested_attributes_for :policy

  # Name conflict with LifeAndDisabilityPolicy model
  def self.policy_class
    LifeAndDisabilityPunditPolicy
  end

  before_save { self.category = Category.fetch("insurance") }
  after_save :clear_beneficiaries

  private
  
  def clear_beneficiaries
    self.policy.each do |policy|
      policy.primary_beneficiaries.clear
      policy.secondary_beneficiaries.clear
    end
  end

  def initialize_category_and_group
    self.group = "life"
  end
end
