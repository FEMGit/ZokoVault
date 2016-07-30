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

  it "renders a list of contacts" do
    render
    assert_select "tr>td", :text => "Firstname".to_s, :count => 2
    assert_select "tr>td", :text => "Lastname".to_s, :count => 2
    assert_select "tr>td", :text => "Emailaddress".to_s, :count => 2
    assert_select "tr>td", :text => "Phone".to_s, :count => 2
    assert_select "tr>td", :text => "Category".to_s, :count => 2
    assert_select "tr>td", :text => "Relationship".to_s, :count => 2
    assert_select "tr>td", :text => "Beneficiarytype".to_s, :count => 2
    assert_select "tr>td", :text => "Ssn".to_s, :count => 2
    assert_select "tr>td", :text => "Address".to_s, :count => 2
    assert_select "tr>td", :text => "Zipcode".to_s, :count => 2
    assert_select "tr>td", :text => "State".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Avatarcolor".to_s, :count => 2
    assert_select "tr>td", :text => "Photourl".to_s, :count => 2
    assert_select "tr>td", :text => "Businessname".to_s, :count => 2
    assert_select "tr>td", :text => "Businesswebaddress".to_s, :count => 2
    assert_select "tr>td", :text => "Businessphone".to_s, :count => 2
    assert_select "tr>td", :text => "Businessfax".to_s, :count => 2
  end
end
