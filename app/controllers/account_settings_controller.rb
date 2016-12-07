class AccountSettingsController < AuthenticatedController
  def index
    @contacts = Contact.for_user(current_user)
  end
end
