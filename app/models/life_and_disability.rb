class LifeAndDisability < Vendor

  has_one :policy, 
    class_name: "LifeAndDisabilityPolicy",
    foreign_key: :vendor_id

  accepts_nested_attributes_for :policy

  private

  def initialize_category_and_group
    self.category = "Insurance"
    self.group = "life"
  end
end
