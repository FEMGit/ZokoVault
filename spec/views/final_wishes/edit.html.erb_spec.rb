require 'rails_helper'

RSpec.describe "final_wishes/edit", type: :view do
  before(:each) do
    assign(:final_wish_info, FinalWishInfo.new(:user_id => 1, :group => "MyString", :id => 1))
    @final_wishes = []
    @group = {"value" => "value", "label" => "label"}
  end

  it "renders the edit final_wish form" do
    render
  end
end
