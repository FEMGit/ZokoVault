class ApplicationMailer < ActionMailer::Base
  default from: '"ZokuVault" <support@zokuvault.com>'
  default to: '"ZokuVault" <support@zokuvault.com>'
  layout 'mailer'
end
