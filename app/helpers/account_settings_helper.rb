module AccountSettingsHelper
  def cvv_code_image
    asset_url('cvv_code.png')
  end
  
  def always_mfa_phone_text
    return '(mandatory for corporate accounts)' if current_user.present? &&
                                                   corporate?
    '(recommended)'
  end
  
  def mfa_options_classes
    return " opacity-half pl-0 " if current_user.present? && corporate?
    " pl-0 "
  end
end
