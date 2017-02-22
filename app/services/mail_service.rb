module MailService
  def self.mail_regexp
    /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  end
  
  def self.email_domain(email)
    email.match(/\A([^@\s]+)@(?:[-a-z0-9]+\.)+([a-z]{2,})\z/i).captures.last
  end
end