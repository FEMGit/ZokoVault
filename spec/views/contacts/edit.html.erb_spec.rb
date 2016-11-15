require 'rails_helper'

RSpec.describe "contacts/edit", type: :view do
  let(:user) { create :user }
  before(:each) do
    current_user = nil
    @contact = assign(:contact, Contact.create!(
      :firstname => "MyString",
      :lastname => "MyString",
      :emailaddress => "MyString",
      :phone => "MyString",
      :contact_type => Contact::CONTACT_TYPES.keys.first,
      :relationship => "MyString",
      :beneficiarytype => "MyString",
      :address => "MyString",
      :zipcode => "MyString",
      :state => "MyString",
      :notes => "MyText",
      :avatarcolor => "MyString",
      :photourl => "MyString",
      :businessname => "MyString",
      :businesswebaddress => "MyString",
      :businessphone => "MyString",
      :businessfax => "MyString",
      user: user
    ))
    user.user_profile.contact = @contact
  end

  before do
    sign_in user
  end

  it "renders the edit contact form" do
    render

    assert_select "form[action=?][method=?]", contact_path(@contact), "post" do

      assert_select "input#contact_firstname[name=?]", "contact[firstname]"

      assert_select "input#contact_lastname[name=?]", "contact[lastname]"

      assert_select "input#contact_emailaddress[name=?]", "contact[emailaddress]"

      assert_select "input#contact_phone[name=?]", "contact[phone]"

      assert_select "select#contact_contact_type[name=?]", "contact[contact_type]"

      assert_select "select#personal_relationships_select[name=?]", "contact[relationship]"

      assert_select "select#common_professional_select[name=?]", "contact[relationship]"

      assert_select "select#medical_professional_select[name=?]", "contact[relationship]"

      assert_select "input#contact_beneficiarytype[name=?]", "contact[beneficiarytype]"

      assert_select "input#contact_address[name=?]", "contact[address]"

      assert_select "input#contact_zipcode[name=?]", "contact[zipcode]"

      assert_select "textarea#contact_notes[name=?]", "contact[notes]"

      assert_select "input#contact_avatarcolor[name=?]", "contact[avatarcolor]"

      assert_select "input#contact_photourl[name=?]", "contact[photourl]"

      assert_select "input#contact_businessname[name=?]", "contact[businessname]"

      assert_select "input#contact_businesswebaddress[name=?]", "contact[businesswebaddress]"

      assert_select "input#contact_businessphone[name=?]", "contact[businessphone]"

      assert_select "input#contact_businessfax[name=?]", "contact[businessfax]"
    end
  end
end
