class WelcomeController < AuthenticatedController
  skip_before_action :authenticate_user!, :complete_setup!, :mfa_verify!, only: [:thank_you, :email_confirmed]

  def index; 
    @shared_resources = 
      UserResourceGatherer.new(current_user).shared_resources.compact
    @shared_users = @shared_resources.map(&:user).uniq
    @new_shares = @shared_resources.select { |resource| resource.created_at > current_user.last_sign_in_at}
  end

  def thank_you; end

  def email_confirmed; end
  
end
