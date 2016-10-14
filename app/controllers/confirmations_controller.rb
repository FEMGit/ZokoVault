class ConfirmationsController < Devise::ConfirmationsController
  protected

  def after_confirmation_path_for(*)
    email_confirmed_path
  end
end
