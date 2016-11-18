require 'rails_helper'

RSpec.describe "final_wishes/index", type: :view do
  before(:each) do
    assign(:final_wishes, [
      FinalWish.create!(
        :document_id => 2,
        :user_id => 3,
        :primary_contact_id => 4,
        :notes => "Notes",
        :group => "Group"
      ),
      FinalWish.create!(
        :document_id => 2,
        :user_id => 3,
        :primary_contact_id => 4,
        :notes => "Notes",
        :group => "Group"
      )
    ])
  end

  it "renders a list of final_wishes" do
    render
  end
end
