require 'rails_helper'

RSpec.describe "relationships/new", type: :view do
  before(:each) do
    assign(:relationship, Relationship.new(
      :name => "MyString",
      :type => ""
    ))
  end

  it "renders new relationship form" do
    render

    assert_select "form[action=?][method=?]", relationships_path, "post" do

      assert_select "input#relationship_name[name=?]", "relationship[name]"

      assert_select "input#relationship_type[name=?]", "relationship[type]"
    end
  end
end
