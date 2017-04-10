ZokuVault::Application.config.mailchimp_secret_token = if Rails.env.development? or Rails.env.test?
  '8f2ae95c6e28ed563da7c841e72e7389-us14'
else
  ENV['MAILCHIMP_API_KEY']
end
