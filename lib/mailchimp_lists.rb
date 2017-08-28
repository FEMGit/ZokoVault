module MailchimpLists
  LIST_TYPES = [:paid, :shared, :trial, :corporate]
  PRODUCTION = { paid: 'Paid Subscriber', shared: 'Shared With User',
     trial: 'Free Trial Users', corporate: 'Corporate Users' }
  BETA = { paid: 'Beta Paid Subscriber', shared: 'Beta Shared With User',
     trial: 'Beta Free Trial Users', corporate: 'Beta Corporate Users' }
end