class MovePowerOfAttorneys < ActiveRecord::Migration
  def change
    # Update Categories of existing POA, Will and Trust cards
    wtl_category = Category.fetch('wills - trusts - legal')
    
    power_of_attorneys = PowerOfAttorney.all
    power_of_attorneys.each do |power_of_attorney|
      next unless User.exists?(power_of_attorney.user_id)
      power_of_attorney_contact = PowerOfAttorneyContact.create(category_id: wtl_category.id, user_id: power_of_attorney.user_id)
      power_of_attorney_contact.power_of_attorneys << power_of_attorney
    end
  end
end
