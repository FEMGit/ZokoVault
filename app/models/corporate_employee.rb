class CorporateEmployee
  include ClassAttributes
  attr_reader :name, :email, :mobile_phone_number, :managed_users,
              :advisor_relationship
  
  def initialize(params = {})
    @name = params[:name]
    @email = params[:email]
    @mobile_phone_number = params[:mobile_phone_number]
    @managed_users = params[:managed_users]
  end
end