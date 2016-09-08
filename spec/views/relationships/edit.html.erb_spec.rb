require 'rails_helper'

RSpec.describe "relationships/edit", type: :view do
  before(:each) do
    @relationship = assign(:relationship, Relationship.create!(
      :name => "MyString",
      :type => ""
    ))
  end

  it "renders the edit relationship form" do
    render

    assert_select "form[action=?][method=?]", relationship_path(@relationship), "post" do

      assert_select "input#relationship_name[name=?]", "relationship[name]"

      assert_select "input#relationship_type[name=?]", "relationship[type]"
    end
  end
end
