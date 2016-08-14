require 'rails_helper'

RSpec.describe "vendors/edit", type: :view do
  before(:each) do
    @vendor = assign(:vendor, Vendor.create!(
      :category => "MyText",
      :group => "MyText",
      :name => "MyText",
      :webaddress => "MyText",
      :phone => "MyText",
      :contact => nil,
      :user => nil
    ))
  end

  it "renders the edit vendor form" do
    render

    assert_select "form[action=?][method=?]", vendor_path(@vendor), "post" do

      assert_select "textarea#vendor_category[name=?]", "vendor[category]"

      assert_select "textarea#vendor_group[name=?]", "vendor[group]"

      assert_select "textarea#vendor_name[name=?]", "vendor[name]"

      assert_select "textarea#vendor_webaddress[name=?]", "vendor[webaddress]"

      assert_select "textarea#vendor_phone[name=?]", "vendor[phone]"

      assert_select "input#vendor_contact_id[name=?]", "vendor[contact_id]"

      assert_select "input#vendor_user_id[name=?]", "vendor[user_id]"
    end
  end
end
