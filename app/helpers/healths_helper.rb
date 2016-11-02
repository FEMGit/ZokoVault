module HealthsHelper
  def policy_type_abbreviate(policy_type)
    words = policy_type.split(' ')
    "#{words.first} #{words.last}"
  end
end
