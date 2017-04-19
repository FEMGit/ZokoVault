require 'rails_helper'

RSpec.describe "life_and_disabilities/new", type: :view do
  let(:contacts) { Array.new(3) { create(:contact, user_id: user.id) } }
  
  let(:user) { create :user }
  
  before(:each) do
    assign(:contacts, [])
    assign(:contacts_shareable, [])
    @insurance_card = assign(:life_and_disability, create(:life_and_disability))
    @account_owners = contacts.collect { |s| [s.id.to_s + '_contact', s.name, class: "contact-item"] }
  end

  it "renders new life form" do
    render
  end
end
