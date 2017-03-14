class Employer < ActiveRecord::Base
  belongs_to :user_profile

  validates_format_of :phone_number_office, 
                      with: /\A\d{3}-\d{3}-\d{4}\z/, 
                      allow_blank: true, 
                      message: "must be in format 222-555-1111"

  validates_format_of :phone_number_fax,
                      with: /\A\d{3}-\d{3}-\d{4}\z/, 
                      allow_blank: true, 
                      message: "must be in format 222-555-1111"
  
  validates :state, inclusion: { in:  States::STATES.map(&:last), allow_blank: true }
  
  validates_length_of :name, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :street_address_1, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :city, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :zip, :maximum => ApplicationController.helpers.get_max_length(:zipcode)
  validates_length_of :web_address, :maximum => (ApplicationController.helpers.get_max_length(:web) + ApplicationController.helpers.get_max_length(:web_prefix))
  
  def address_parts
    [
      "#{street_address_1} #{street_address_2}".strip,
      "#{city}, #{state} #{zip}".strip
    ]
  end
end
