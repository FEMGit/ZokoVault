class CorporateAccountProfile < ActiveRecord::Base
  scope :for_user, ->(user) { where(user: user) }
  
  belongs_to :user
  
  validates_length_of :business_name, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :web_address, :maximum => (ApplicationController.helpers.get_max_length(:web) + ApplicationController.helpers.get_max_length(:web_prefix))
  validates_length_of :street_address, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :city, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :zip, :maximum => ApplicationController.helpers.get_max_length(:zipcode)
  validates :state, inclusion: { in:  States::STATES.map(&:last), allow_blank: true }
  validates_format_of :phone_number,
    with: /\A\d{3}-\d{3}-\d{4}\z/,
    allow_blank: true,
    message: "must be in format 222-555-1111"
  
  validates_format_of :fax_number,
    with: /\A\d{3}-\d{3}-\d{4}\z/,
    allow_blank: true,
    message: "must be in format 222-555-1111"
  
  validates_format_of :web_address,
                      :with => Validation::WEB_ADDRESS_URL,
                      :message => "Please enter a valid url (starts with 'http://' or 'https://')",
                      :allow_blank => true
end
