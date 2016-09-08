require 'rails_helper'

RSpec.describe "relationships/index", type: :view do
  before(:each) do
    assign(:relationships, [
      Relationship.create!(
        :name => "Name",
        :type => "Type"
      ),
      Relationship.create!(
        :name => "Name",
        :type => "Type"
      )
    ])
  end

  it "renders a list of relationships" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Type".to_s, :count => 2
  end
end
