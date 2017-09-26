module PageTitle
  def self.included(base)
    base.before_filter :set_page_title
  end
  
  LOGGED_OUT_MARKETING_PAGES = {
    home: "ZokuVault - Virtual Safety Deposit box and estate planning portal.",
    about_us: "ZokuVault - We help families plan, organize, and share the important details of their lives.",
    security: "ZokuVault - Secure digital online vault.",
    corporate: "ZokuVault - ZokuVault helps professionals and corporations increase engagement with their clients.",
    pricing: "ZokuVault - Low cost annual pricing.",
    contact_us: "ZokuVault - Contact us for more information.",
    sign_up: "ZokuVault - Free Trial Sign Up.",
    login: "ZokuVault Login",
    setup: "ZokuVault easy life planning storage and setup.",
    terms_of_service: "ZokuVault - Terms of Service",
    careers: "ZokuVault - Careers",
    privacy_policy: "ZokuVault - Privacy Policy",
    resend_unlock_instructions: "ZokuVault - Resend unlock instructions",
    resend_confirmation_instructions: "ZokuVault - Resend confirmation instructions",
    send_reset_password_instructions: "ZokuVault - Send reset password instructions",
    password_setup: "ZokuVault - Password setup"
  }
  
  private
  
  def set_page_title
    @title = page_name.blank? ? "ZokuVault" : "ZokuVault - #{page_name}"
  end
  
  def page_name; end
end
