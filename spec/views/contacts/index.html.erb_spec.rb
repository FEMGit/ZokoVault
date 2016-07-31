require 'rails_helper'

RSpec.describe "contacts/index", type: :view do
  before(:each) do
    assign(:contacts, [
      Contact.create!(
        :firstname => "Firstname",
        :lastname => "Lastname",
        :emailaddress => "Emailaddress",
        :phone => "Phone",
        :category => "Category",
        :relationship => "Relationship",
        :beneficiarytype => "Beneficiarytype",
        :ssn => "Ssn",
        :address => "Address",
        :zipcode => "Zipcode",
        :state => "State",
        :notes => "MyText",
        :avatarcolor => "Avatarcolor",
        :photourl => "Photourl",
        :businessname => "Businessname",
        :businesswebaddress => "Businesswebaddress",
        :businessphone => "Businessphone",
        :businessfax => "Businessfax"
      ),
      Contact.create!(
        :firstname => "Firstname",
        :lastname => "Lastname",
        :emailaddress => "Emailaddress",
        :phone => "Phone",
        :category => "Category",
        :relationship => "Relationship",
        :beneficiarytype => "Beneficiarytype",
        :ssn => "Ssn",
        :address => "Address",
        :zipcode => "Zipcode",
        :state => "State",
        :notes => "MyText",
        :avatarcolor => "Avatarcolor",
        :photourl => "Photourl",
        :businessname => "Businessname",
        :businesswebaddress => "Businesswebaddress",
        :businessphone => "Businessphone",
        :businessfax => "Businessfax"
      )
    ])
  end

  
end
