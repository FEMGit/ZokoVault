module MailerInjection
  def inject(hash)
    hash.keys.each do |key|
      define_method key.to_sym do
        eval " @#{key} = hash[key] "
      end
    end
  end
end

class ActionMailer::Preview
  extend MailerInjection
end

class ActionMailer::Base
  extend MailerInjection
end

class ActionController::Base
  before_filter :inject_request
  
  def inject_request
    ActionMailer::Preview.inject({ request: request })
    ActionMailer::Base.inject({ request: request })
  end
end
