require 'rails_helper'

RSpec.describe "healths/new", type: :view do
  let(:contacts) { Array.new(3) { create(:contact, user_id: user.id) } }
  
  let(:user) { create :user }
  
  before(:each) do
    assign(:contacts, [])
    assign(:contacts_shareable, [])
    @insurance_card = assign(:health, create(:health))
    @account_owners = contacts.collect { |s| [s.id.to_s + '_contact', s.name, class: "contact-item"] }
  end

  it "renders new health form" do
    render
  end
end
