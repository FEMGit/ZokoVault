class UserService
  def self.update_user_information(user_models = nil)
    threads = []
    [1, 2, 3].each do |thread_num|
      threads << Thread.new do
        if thread_num == 1
          update_site_completed(user_models)
          ActiveRecord::Base.connection.close
        elsif thread_num == 2
          update_categories_count
          ActiveRecord::Base.connection.close
        else
          update_subcategories_count
          ActiveRecord::Base.connection.close
        end
      end
    end
    threads.each(&:join)
  end
  
  def self.update_site_completed(user_models = nil)
    if user_models.blank?
      Rails.application.eager_load!
      all_models = ActiveRecord::Base.descendants
      all_models.delete(UserDeathTrap)
      all_models.delete(UserActivity)
      all_models.delete(Category)
      user_models = all_models.select { |x| x.table_exists? && x.column_names.include?("user_id") }
    end
    
    User.all.map(&:id).each do |user_id|
      completed_count = user_models.select { |x| x.where(:user_id => user_id).any? }.count
      models_with_user_count = user_models.count
      User.find_by(id: user_id).update(site_completed: ((completed_count.to_f / models_with_user_count) * 100).round(2))
    end
  end
  
  def self.update_categories_count
    User.all.map(&:id).each do |user_id|
      user = User.find_by(id: user_id)
      contact_service = ContactService.new(:user => user)

      category_count = if_any_return_one(FinancialProvider.for_user(user)) + 
                          if_any_return_one(CardDocument.for_user(user)
                                                        .where(category: Category.fetch(Rails.application.config.x.WillsPoaCategory.downcase))) + 
                          if_any_return_one(CardDocument.for_user(user)
                                                        .where(category: Category.fetch(Rails.application.config.x.TrustsEntitiesCategory.downcase))) +
                          if_any_return_one(Vendor.for_user(user)) +
                          if_any_return_one(TaxYearInfo.for_user(user)) +
                          if_any_return_one(FinalWishInfo.for_user(user)) +
                          if_any_return_one(contact_service.contacts_shareable)
        
        user.update(category_count: category_count)
    end
  end
  
  def self.update_subcategories_count
    User.all.map(&:id).each do |user_id|
      user = User.find_by(id: user_id)
      
      subcategory_count = financial_information_count(user) + 
                            wills_powers_of_attorney_count(user) +
                            trusts_entities_count(user) + 
                            insurance_count(user) + 
                            taxes_count(user) + 
                            final_wishes_count(user) +
                            contacts_count(user)
      user.update(subcategory_count: subcategory_count)
    end
  end
  
  private
  
  def self.contacts_count(user)
    contact_service = ContactService.new(:user => user)
    contact_service.contacts_shareable.count
  end
  
  def self.final_wishes_count(user)
    FinalWishInfo.for_user(user).count
  end
  
  def self.taxes_count(user)
    TaxYearInfo.for_user(user).count
  end
  
  def self.insurance_count(user)
    Vendor.for_user(user).count
  end
  
  def self.trusts_entities_count(user)
    Trust.for_user(user).count + 
      Entity.for_user(user).count
  end
  
  def self.wills_powers_of_attorney_count(user)
    Will.for_user(user).count +
      PowerOfAttorneyContact.for_user(user).count
  end
  
  def self.financial_information_count(user)
    FinancialAccountInformation.for_user(user).count +
      FinancialInvestment.for_user(user).count +
      FinancialAlternative.for_user(user).count +
      FinancialProperty.for_user(user).count
  end
  
  def self.if_any_return_one(object)
    object.any? ? 1 : 0
  end
end