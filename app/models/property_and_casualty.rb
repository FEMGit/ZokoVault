class PropertyAndCasualty < Vendor
  has_many :policy, 
    class_name: "PropertyAndCasualtyPolicy",
    foreign_key: :vendor_id

  accepts_nested_attributes_for :policy

  # Name conflict with PropertyAndCasualtyPolicy model
  def self.policy_class
    PropertyAndCasualtyPunditPolicy
  end

  before_save { self.category = Category.fetch("insurance") }

  private

  def initialize_category_and_group
    self.group = "property"
  end

end
