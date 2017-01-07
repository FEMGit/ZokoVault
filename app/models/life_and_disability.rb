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

  private

  def initialize_category_and_group
    self.group = "life"
  end
end
