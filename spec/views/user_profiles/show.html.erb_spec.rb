require 'rails_helper'

RSpec.describe "user_profiles/show", type: :view do
  let(:user) { build(:user) }
  before(:each) do
    @user_profile = assign(:user_profile, UserProfile.new(user: user))
  end

  it "renders attributes in <p>" do
    render
  end
end
