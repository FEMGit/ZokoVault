class UpdateFinancialSubtutorialNames < ActiveRecord::Migration
  def change
    Subtutorial.find_by(name: "I have a financial advisor.").update(name: "My financial advisor.")
    Subtutorial.find_by(name: "I have a checking account.").update(name: "My checking account.")
    Subtutorial.find_by(name: "I have investments.").update(name: "My investments.")
    Subtutorial.find_by(name: "I have mortgage.").update(name: "My mortgage.")
    Subtutorial.find_by(name: "I have valuable property.").update(name: "My valuable property.")
    Subtutorial.find_by(name: "I have credit cards.").update(name: "My credit cards")
    Subtutorial.find_by(name: "I have jewelry.").update(name: "My jewelry.")
    Subtutorial.find_by(name: "I have alternative investments.").update(name: "My alternative investments.")
    Subtutorial.find_by(name: "I own a business.").update(name: "My business.")
  end
end
