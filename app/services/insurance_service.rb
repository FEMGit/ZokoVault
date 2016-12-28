class InsuranceService
  def initialize(user)
    @user = user
  end
  
  def group_by_vendor(vendor)
    group_name = Vendor.for_user(@user).find_by(id: vendor).try(:group)
    insurance_groups = Rails.configuration.x.categories.select { |category| category == "Insurance" }
    insurance_groups.values.first["groups"].detect { |x| x["value"] == group_name }["label"]
  end
end
