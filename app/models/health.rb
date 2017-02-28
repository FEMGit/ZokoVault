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
  after_save :clear_insured_members

  private
  
  def clear_insured_members
    self.policy.each do |policy|
      policy.insured_members.clear
    end
  end
  
  def initialize_category_and_group
    self.group = "health"
  end
end
