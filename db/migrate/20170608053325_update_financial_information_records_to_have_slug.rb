class UpdateFinancialInformationRecordsToHaveSlug < ActiveRecord::Migration
  def change
    FinancialAccountInformation.find_each(:batch_size => 1000) do |financial_record|
      financial_record.save!
    end
    
    FinancialAlternative.find_each(:batch_size => 1000) do |financial_record|
      financial_record.save!
    end
    
    FinancialInvestment.find_each(:batch_size => 1000) do |financial_record|
      financial_record.save!
    end
    
    FinancialProperty.find_each(:batch_size => 1000) do |financial_record|
      financial_record.save!
    end
    
    FinancialProvider.find_each(:batch_size => 1000) do |financial_record|
      financial_record.save!
    end
  end
end
