class ConfirmationsController < Devise::ConfirmationsController

protected
  def after_confirmation_path_for(resource_name, resource)
    email_confirmed_path
  end
end
