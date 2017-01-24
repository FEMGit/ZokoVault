class FinancialAccountInformation < ActiveRecord::Base
  enum account_type: ["Checking",
                      "Savings",
                      "Brokerage",
                      "Stock",
                      "Bond",
                      "Derivative",
                      "Government Security",
                      "Mutual Fund",
                      "IRA",
                      "Roth IRA",
                      "401K",
                      "403B",
                      "529",
                      "REIT",
                      "Credit Card",
                      "Mortgage",
                      "Auto Loan",
                      "Line of Credit",
                      "Business Loan",
                      "Student Loan",
                      "Undrawn Commitment"]

  scope :for_user, ->(user) { where(user: user) }
  
  scope :cash, ->(user) { where(user: user, account_type: FinancialInformation::ACCOUNT_CASH) }
  scope :investments, ->(user) { where(user: user, account_type: FinancialInformation::ACCOUNT_INVESTMENTS) }
  scope :credit_cards, ->(user) { where(user: user, account_type: FinancialInformation::ACCOUNT_CREDIT_CARDS) }
  scope :loans, ->(user) { where(user: user, account_type: FinancialInformation::ACCOUNT_LOANS) }
  
  belongs_to :user
  belongs_to :primary_contact_broker, class_name: "Contact"
  belongs_to :owner, class_name: "Contact"
  
  before_save { self.category = Category.fetch("financial information") }
end
