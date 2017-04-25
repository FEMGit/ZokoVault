require 'set'

class Funding < ActiveRecord::Base

  belongs_to :user_subscription, inverse_of: :funding

  METHODS = Set.new(%w{
    beta_user_gift stripe_onetime_payment stripe_subscription trial
  }).freeze

  validates :user_subscription, presence: true
  validates :details, presence: true
  validates :method, inclusion: { in: METHODS }

end
