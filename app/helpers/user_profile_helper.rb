module UserProfileHelper
  def web_address(employer)
    link_to(employer.web_address, employer.web_address)
  end
end
