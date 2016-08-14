require 'rails_helper'

RSpec.describe "vendors/index", type: :view do
  before(:each) do
    assign(:vendors, [
      Vendor.create!(
        :category => "MyText",
        :group => "MyText",
        :name => "MyText",
        :webaddress => "MyText",
        :phone => "MyText",
        :contact => nil,
        :user => nil
      ),
      Vendor.create!(
        :category => "MyText",
        :group => "MyText",
        :name => "MyText",
        :webaddress => "MyText",
        :phone => "MyText",
        :contact => nil,
        :user => nil
      )
    ])
  end

  it "renders a list of vendors" do
    render
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
