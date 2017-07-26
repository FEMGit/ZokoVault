module UserPageAccess
  def self.permitted_shared_view
    ['shared_view', 'wills', 'power_of_attorneys', 'trusts', 'entities', 'financial_account', 'financial_alternative', 'financial_information', 'financial_investment', 'financial_property',
               'healths', 'property_and_casualties', 'life_and_disabilities', 'taxes', 'final_wishes', 'documents', 'contacts', 'online_accounts']
  end

  CONTROLLERS = {
    :free => ['shares', 'email_support', 'account_settings', 'account_traffics', 'user_profiles', 'shared_view', 'corporate_accounts', 'mfas', 'accounts'],
    :corporate => { general_view: ['documents', 'email_support', 'account_settings', 'account_traffics', 'user_profiles', 'shared_view', 'corporate_accounts', 'corporate_employees', 'mfas', 'accounts', 'usage_metrics', 'users', ],
                    shared_view: permitted_shared_view },
    :corporate_employee => { general_view: ['documents', 'email_support', 'account_settings', 'account_traffics', 'user_profiles', 'shared_view', 'corporate_accounts', 'mfas', 'accounts', 'usage_metrics', 'users'],
                             shared_view: permitted_shared_view },
    :trial_expired => []
  }
end
