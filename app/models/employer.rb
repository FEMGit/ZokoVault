class Employer < ActiveRecord::Base
  belongs_to :user_profile

  validates :name, presence: true

  validates_format_of :phone_number_office, 
                      with: /\d{3}-\d{3}-\d{4}/, 
                      allow_blank: true, 
                      message: "must be in format 222-555-1111"

  validates_format_of :phone_number_fax,
                      with: /\d{3}-\d{3}-\d{4}/, 
                      allow_blank: true, 
                      message: "must be in format 222-555-1111"

  def address_parts
    [
      "#{street_address_1} #{street_address_2}".strip,
      "#{city}, #{state} #{zip}".strip
    ]
  end
end