class FinancialAlternative < ActiveRecord::Base
  enum alternative_type: ["Venture Capital",
                          "Private Equity",
                          "Hedge Fund",
                          "Seed",
                          "Angel",
                          "Other Alternatives"]

  scope :for_user, ->(user) { where(user: user) }
  
  scope :alternatives, ->(user) { where(user: user, alternative_type: FinancialInformation::ALTERNATIVES) }
  
  belongs_to :user
  belongs_to :category
  belongs_to :primary_contact, class_name: "Contact"
  belongs_to :owner, class_name: "Contact"
end
