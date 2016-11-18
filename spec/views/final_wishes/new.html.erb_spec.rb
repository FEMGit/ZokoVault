require 'rails_helper'

RSpec.describe "final_wishes/new", type: :view do
  before(:each) do
    assign(:final_wish_info, FinalWishInfo.new(:user_id => 1, :group => "MyString"))
  end

  it "renders new final_wish form" do
    render
    assert_select "form[action=?][method=?]", final_wishes_path, "post" do

      assert_select "input#final_wish_id_0"

      assert_select "#final_wish_notes_id_0"

      assert_select "#final_wish_share_id_0"
    end
  end
end
