module AccountsHelper
  def radio_button_checked?(value, mfa_frequency)
    return "checked" if mfa_frequency == value
  end
end
