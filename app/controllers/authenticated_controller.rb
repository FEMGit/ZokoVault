class AuthenticatedController < ApplicationController
  before_action :authenticate_user! , :complete_setup!

private

  def complete_setup!
    unless current_user.setup_complete?
      redirect_to setup_account_path 
    end
  end
end
