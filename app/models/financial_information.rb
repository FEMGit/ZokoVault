class FinancialInformation
  FINANCIAL_INFORMATION_TYPES = {
    cash: [
      "Checking",
      "Savings",
      "Government Security"
    ],
    investments: [
      "Brokerage",
      "Stock",
      "Bond",
      "Derivative",
      "Mutual Fund",
      "IRA",
      "Roth IRA",
      "401K",
      "403B",
      "529",
      "REIT",
      "Venture Capital",
      "Private Equity",
      "Hedge Fund",
      "Other Alternatives",
      "Private Company Stock",
      "Private Company Debt",
      "Royalty",
      "Other Investments"
    ],
    loans: [
      "Mortgage",
      "Auto Loan",
      "Line of Credit",
      "Business Loan",
      "Student Loan",
      "Undrawn Commitment",
      "IOU",
      "Other Loans"
    ],
    properties: [
      "House",
      "Land",
      "Commercial",
      "Vehicle",
      "Jewelry",
      "Artwork",
      "Furniture",
      "Antiquity",
      "Heirloom",
      "Valuable",
      "Other Property"
    ],
    credit_cards: [
      "Credit Card"
    ],
    alternatives: [
      "Venture Capital",
      "Private Equity",
      "Hedge Fund",
      "Seed",
      "Angel",
      "Other Alternatives"
    ]
  }.freeze
  
  def self.net_worth_groups(specific_group, net_worth_groups)
    specific_group.select { |k, _v| net_worth_groups.include? k }.values
  end
  
  def self.credit_card_types
    FINANCIAL_INFORMATION_TYPES[:credit_cards]
  end
  
  ACCOUNT_CASH = net_worth_groups(FinancialAccountInformation.account_types, FinancialInformation::FINANCIAL_INFORMATION_TYPES[:cash])
  ACCOUNT_INVESTMENTS = net_worth_groups(FinancialAccountInformation.account_types, FinancialInformation::FINANCIAL_INFORMATION_TYPES[:investments])
  ACCOUNT_LOANS = net_worth_groups(FinancialAccountInformation.account_types, FinancialInformation::FINANCIAL_INFORMATION_TYPES[:loans])
  ACCOUNT_CREDIT_CARDS = net_worth_groups(FinancialAccountInformation.account_types, FinancialInformation::FINANCIAL_INFORMATION_TYPES[:credit_cards])
  PROPERTIES = net_worth_groups(FinancialProperty.property_types, FinancialInformation::FINANCIAL_INFORMATION_TYPES[:properties])
  
  INVESTMENT_LOANS = net_worth_groups(FinancialInvestment.investment_types, FinancialInformation::FINANCIAL_INFORMATION_TYPES[:loans])
  INVESTMENTS = net_worth_groups(FinancialInvestment.investment_types, FinancialInformation::FINANCIAL_INFORMATION_TYPES[:investments])
  
  ALTERNATIVES = net_worth_groups(FinancialAlternative.alternative_types, FinancialInformation::FINANCIAL_INFORMATION_TYPES[:alternatives])
end
