require 'rails_helper'

RSpec.describe "interested_users/index", type: :view do
  before(:each) do
    assign(:interested_users, [
      InterestedUser.create!,
      InterestedUser.create!
    ])
  end

  it "renders a list of interested_users" do
    render
  end
end
