module UserPageAccess
  CONTROLLERS = {
    :free => ['shares', 'email_support', 'account_settings', 'account_traffics', 'user_profiles', 'shared_view', 'corporate_accounts', 'mfas', 'accounts'],
    :corporate => ['email_support', 'account_settings', 'account_traffics', 'user_profiles', 'shared_view', 'corporate_accounts', 'corporate_employees', 'mfas', 'accounts', 'usage_metrics', 'users'],
    :corporate_employee => ['email_support', 'account_settings', 'account_traffics', 'user_profiles', 'shared_view', 'corporate_accounts', 'mfas', 'accounts', 'usage_metrics', 'users'],
    :trial_expired => []
  }
end