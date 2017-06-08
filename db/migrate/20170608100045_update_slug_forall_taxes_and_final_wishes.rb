class UpdateSlugForallTaxesAndFinalWishes < ActiveRecord::Migration
  def change
    Tax.find_each(:batch_size => 1000) do |tax|
      next unless tax.user
      tax.save!
    end
    
    TaxYearInfo.find_each(:batch_size => 1000) do |tax|
      next unless tax.user
      tax.save!
    end
    
    FinalWish.find_each(:batch_size => 1000) do |final_wish|
      next unless final_wish.user
      final_wish.save!
    end
    
    FinalWishInfo.find_each(:batch_size => 1000) do |final_wish|
      next unless final_wish.user
      final_wish.save!
    end
  end
end
