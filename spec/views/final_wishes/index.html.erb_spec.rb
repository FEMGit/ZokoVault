require 'rails_helper'

RSpec.describe "final_wishes/index", type: :view do
  before(:each) do
    assign(:category, Category.fetch(Rails.application.config.x.FinalWishesCategory.downcase),)
    assign(:final_wishes, [
      FinalWish.create!(
        :document_id => 2,
        :user_id => 3,
        :primary_contact_id => 4,
        :notes => "Notes"
      ),
      FinalWish.create!(
        :document_id => 2,
        :user_id => 3,
        :primary_contact_id => 4,
        :notes => "Notes"
      )
    ])
  end

  it "renders a list of final_wishes" do
    render
  end
end