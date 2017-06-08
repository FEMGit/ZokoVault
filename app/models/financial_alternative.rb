class FinancialAlternative < ActiveRecord::Base
  # Friendly Id
  extend FriendlyId
  friendly_id :slug_candidates
  
  def should_generate_new_friendly_id?
    name_changed? || alternative_type_changed? || ((name.present? || alternative_type.present?) && slug.blank?)
  end
  
  def slug_candidates
    [
      :name,
      [:name, :alternative_type]
    ]
  end
  
  enum alternative_type: ["Venture Capital",
                          "Private Equity",
                          "Hedge Fund",
                          "Seed",
                          "Angel",
                          "Other Alternatives"]

  has_many :account_owners, as: :contactable, dependent: :destroy, :class_name => 'AccountPolicyOwner'
  
  scope :for_user, ->(user) { where(user: user) }
  
  scope :alternatives, ->(user) { where(user: user, alternative_type: FinancialInformation::ALTERNATIVES) }
  
  belongs_to :user
  belongs_to :category
  belongs_to :primary_contact, class_name: "Contact"
  before_save { self.category = Category.fetch("financial information") }
  
  validates_length_of :commitment, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :total_calls, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :total_distributions, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :current_value, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :name, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :notes, :maximum => ApplicationController.helpers.get_max_length(:notes)
end
