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
    setup: "ZokuVault easy life planning storage and setup."
  }
  
  private
  
  def set_page_title
    @title = page_name.blank? ? "ZokuVault" : "ZokuVault - #{page_name}"
  end
  
  def page_name; end
end
