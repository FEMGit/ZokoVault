require 'rails_helper'

RSpec.describe "interested_users/index", type: :view do
  before(:each) do
    assign(:interested_users, [
      InterestedUser.create!(:name => "1", :email => "1@1"),
      InterestedUser.create!(:name => "2", :email => "2@2")
    ])
  end

  it "renders a list of interested_users" do
    render
  end
end
