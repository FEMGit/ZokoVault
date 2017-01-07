class Health < Vendor
  has_many :policy, 
    class_name: "HealthPolicy",
    foreign_key: :vendor_id

  accepts_nested_attributes_for :policy

  # Name conflict with HealthPolicy model
  def self.policy_class
    HealthPunditPolicy
  end

  before_save { self.category = Category.fetch("insurance") }

  private

  def initialize_category_and_group
    self.group = "health"
  end
end
