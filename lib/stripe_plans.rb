module StripePlans
  YEARLY_PLAN = ENV['STRIPE_YEARLY_PLAN'] || case
    when Rails.env.development? then 'zoku-yearly-v1'
    when ENV['STAGING_TYPE'] == 'develop' then 'zoku-yearly-v1'
    else 'zoku-annual-119.88'
  end
end
