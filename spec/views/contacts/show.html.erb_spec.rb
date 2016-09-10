require 'rails_helper'

RSpec.describe "contacts/show", type: :view do
  let(:user) { create :user }
  let(:relationship_params) { { relationship: 'Son'} }

  let(:options) do
    {
      :firstname => "Firstname",
      :lastname => "Lastname",
      :emailaddress => "Emailaddress",
      :phone => "Phone",
      :contact_type => "Contact Type",
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
    }
  end

  before(:each) do
    assign(:contact, Contact.create!(options.merge(relationship_params)))
  end

  it "renders common attributes" do
    render
    expect(rendered).to match(/Firstname/)
    expect(rendered).to match(/Lastname/)
    expect(rendered).to match(/Emailaddress/)
    expect(rendered).to match(/Phone/)
    expect(rendered).to match(/Contact Type/)
    expect(rendered).to match(/Relationship/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Avatarcolor/)
    expect(rendered).to match(/Photourl/)
  end

  context "personal relation" do
    let(:relationship_params) { { relationship: 'Son'} }

    it "renders personal attributes" do
      render
      expect(rendered).to match(/Beneficiarytype/)
      expect(rendered).to match(/Ssn/)
      expect(rendered).to match(/Address/)
      expect(rendered).to match(/Zipcode/)
    end
  end

  context "professional relationship" do
    let(:relationship_params) { { relationship: 'Attorney'} }

    it "renders professional attributes" do
      render
      expect(rendered).to match(/Businessname/)
      expect(rendered).to match(/Businesswebaddress/)
      expect(rendered).to match(/Businessphone/)
      expect(rendered).to match(/Businessfax/)
    end
  end
end
