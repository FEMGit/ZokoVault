require 'rails_helper'

RSpec.describe "vendor_accounts/new", type: :view do
  before(:each) do
    assign(:vendor_account, VendorAccount.new(
      :name => "MyString",
      :group => "MyString",
      :category => "MyString",
      :vendor => nil
    ))
  end

  it "renders new vendor_account form" do
    render

    assert_select "form[action=?][method=?]", vendor_accounts_path, "post" do

      assert_select "input#vendor_account_name[name=?]", "vendor_account[name]"

      assert_select "input#vendor_account_group[name=?]", "vendor_account[group]"

      assert_select "input#vendor_account_category[name=?]", "vendor_account[category]"

      assert_select "input#vendor_account_vendor_id[name=?]", "vendor_account[vendor_id]"
    end
  end
end
