require 'rails_helper'

RSpec.describe "vendor_accounts/index", type: :view do
  before(:each) do
    assign(:vendor_accounts, [
      VendorAccount.create!(
        :name => "Name",
        :group => "Group",
        :category => "Category",
        :vendor => nil
      ),
      VendorAccount.create!(
        :name => "Name",
        :group => "Group",
        :category => "Category",
        :vendor => nil
      )
    ])
  end

  it "renders a list of vendor_accounts" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Group".to_s, :count => 2
    assert_select "tr>td", :text => "Category".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
