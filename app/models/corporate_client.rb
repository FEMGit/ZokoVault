class CorporateClient
  include ClassAttributes
  attr_reader :name, :email, :phone_number, :mobile_phone_number, :date_of_birth,
                :street, :city, :state, :zip, :has_logged_in, :managed_by
  
  def initialize(params = {})
    @name = params[:name]
    @email = params[:email]
    @phone_number = params[:phone_number]
    @mobile_phone_number = params[:mobile_phone_number]
    @date_of_birth = params[:date_of_birth]
    @street = params[:street]
    @city = params[:street]
    @state = params[:state]
    @zip = params[:zip]
    @has_logged_in = params[:has_logged_in]
    @managed_by = params[:managed_by]
  end
end