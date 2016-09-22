class WelcomeController < AuthenticatedController
  skip_before_action :authenticate_user!, :complete_setup!, :mfa_verify!, only: :thank_you

  def index
  end

  def thank_you
  end

end
