require 'rails_helper'

RSpec.describe "contacts/show", type: :view do
  let(:user) { create :user }
  let(:email) { Faker::Internet.free_email }
  let(:relationship_params) { { relationship: 'Son'} }

  let(:options) do
    {
      :firstname => "Firstname",
      :lastname => "Lastname",
      :emailaddress => email,
      :phone => "Phone",
      :contact_type => Contact::CONTACT_TYPES.keys.first,
      :beneficiarytype => "Beneficiarytype",
      :address => "Address",
      :zipcode => "11111",
      :city => "City",
      :state => States::STATES.map(&:last).first,
      :notes => "MyText",
      :photourl => "Photourl",
      :businessname => "Businessname",
      :businesswebaddress => "Businesswebaddress",
      :businessphone => "Business Phone",
      :businessfax => "Business Fax",
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
    expect(rendered).to match(/#{email}/)
    expect(rendered).to match(/Phone/)
    expect(rendered).to match(/Contact Type/)
    expect(rendered).to match(/Relationship/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Photourl/)
  end

  context "personal relation" do
    let(:relationship_params) { { relationship: 'Son'} }

    it "renders personal attributes" do
      render
      expect(rendered).to match(/Beneficiarytype/)
      expect(rendered).to match(/Address/)
      expect(rendered).to match(/11111/)
    end
  end

  context "professional relationship" do
    let(:relationship_params) { { relationship: 'Attorney'} }

    it "renders professional attributes" do
      render
      expect(rendered).to match(/Businessname/)
      expect(rendered).to match(/Businesswebaddress/)
      expect(rendered).to match(/Business Phone/)
      expect(rendered).to match(/Business Fax/)
    end
  end
end
