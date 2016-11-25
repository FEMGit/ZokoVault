require 'rails_helper'

RSpec.describe "final_wishes/show", type: :view do
  before(:each) do
    @final_wish = assign(:final_wish, FinalWishInfo.create!(:group => "Group"))
    @group = {"value" => "Group", "label" => "Group"}
  end

  it "renders attributes in <p>" do
    render
  end
end
