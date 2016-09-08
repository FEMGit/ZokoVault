require 'rails_helper'

RSpec.describe "relationships/show", type: :view do
  before(:each) do
    @relationship = assign(:relationship, Relationship.create!(
      :name => "Name",
      :type => "Type"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Type/)
  end
end
