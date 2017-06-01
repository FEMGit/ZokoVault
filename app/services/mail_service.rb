module MailService
  def self.email_is_valid?(emailaddress, errors, email_field)
    unless check_domain(emailaddress) &&
        !MailService.contains_blacklisted_symbols?(emailaddress)
      errors.add(email_field, "Email should contain @ and domain like .com")
    end
  end
  
  private
  
  def self.mail_regexp
    /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  end
  
  def self.email_domain(email)
    email_match = email.match(/\A([^@\s]+)@(?:[-a-z0-9]+\.)+([a-z]{2,})\z/i)
    return '' unless email_match.present?
    email_match.captures.last
  end
  
  def self.contains_blacklisted_symbols?(email)
    email.match(/[<>%\;]/)
  end
  
  def self.check_domain(email)
    email_domain = MailService.email_domain(email)
    if EmailDomains::DOMAINS.any? { |dom| email_domain =~ dom }
      return true
    end
    false
  end
end