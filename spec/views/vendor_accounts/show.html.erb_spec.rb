require 'rails_helper'

RSpec.describe "vendor_accounts/show", type: :view do
  before(:each) do
    @vendor_account = assign(:vendor_account, VendorAccount.create!(
      :name => "Name",
      :group => "Group",
      :category => "Category",
      :vendor => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Group/)
    expect(rendered).to match(/Category/)
    expect(rendered).to match(//)
  end
end
