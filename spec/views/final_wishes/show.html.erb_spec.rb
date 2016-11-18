require 'rails_helper'

RSpec.describe "final_wishes/show", type: :view do
  before(:each) do
    @final_wish = assign(:final_wish, FinalWish.create!(:notes => "Notes"))
    @group = {"value" => "Group", "label" => "Group"}
  end

  it "renders attributes in <p>" do
    render
  end
end
