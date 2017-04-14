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
  after_destroy :clean_policies

  private
  
  def clear_beneficiaries
    self.policy.each do |policy|
      policy.secondary_beneficiaries.clear
      policy.policy_holder = nil
    end
  end

  def initialize_category_and_group
    self.group = "life"
  end
  
  def clean_policies
    self.policy.each do |policy|
      LifeAndDisabilityPoliciesPrimaryBeneficiary.where(life_and_disability_policy_id: policy.id).destroy_all
      LifeAndDisabilityPoliciesSecondaryBeneficiary.where(life_and_disability_policy_id: policy.id).destroy_all
    end
  end
end
