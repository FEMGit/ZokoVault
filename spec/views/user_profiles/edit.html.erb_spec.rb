require 'rails_helper'

RSpec.describe "user_profiles/edit", type: :view do
  before(:each) do
    assign(:contacts, [])
    @user_profile = assign(:user_profile, create(:user_profile, user: create(:user)))
  end

  it "renders the edit user_profile form" do
    render

    assert_select "form[action=?][method=?]", user_profile_path, "post" do
    end
  end
end
