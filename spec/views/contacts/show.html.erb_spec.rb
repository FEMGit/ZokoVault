require 'rails_helper'

RSpec.describe "contacts/show", type: :view do
  let(:user) { create :user }
  before(:each) do
    @contact = assign(:contact, Contact.create!(
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
      :businessfax => "Businessfax",
      user: user
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Firstname/)
    expect(rendered).to match(/Lastname/)
    expect(rendered).to match(/Emailaddress/)
    expect(rendered).to match(/Phone/)
    expect(rendered).to match(/Category/)
    expect(rendered).to match(/Relationship/)
    expect(rendered).to match(/Beneficiarytype/)
    expect(rendered).to match(/Ssn/)
    expect(rendered).to match(/Address/)
    expect(rendered).to match(/Zipcode/)
    expect(rendered).to match(/State/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Avatarcolor/)
    expect(rendered).to match(/Photourl/)
    expect(rendered).to match(/Businessname/)
    expect(rendered).to match(/Businesswebaddress/)
    expect(rendered).to match(/Businessphone/)
    expect(rendered).to match(/Businessfax/)
  end
end
