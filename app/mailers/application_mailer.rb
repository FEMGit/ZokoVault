class ApplicationMailer < ActionMailer::Base
  default from: "ZokuVault <noreply@zokuvault.com>"
  default to: "ZokuVault <support@zokuvault.com>"
  layout 'mailer'
end
