class RemoveFinancialAdvisorTutorial < ActiveRecord::Migration
  def change
    Tutorial.where(name: 'Add Financial Advisor').destroy_all
  end
end
