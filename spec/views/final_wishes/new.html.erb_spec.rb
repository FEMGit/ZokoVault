require 'rails_helper'

RSpec.describe "final_wishes/new", type: :view do
  before(:each) do
    assign(:final_wish, FinalWish.new(
                          :document_id => 1,
                          :user_id => 1,
                          :primary_contact_id => 1,
                          :notes => "MyString",
                          :group => "MyString"
    ))
  end

  it "renders new final_wish form" do
    render
    # Disable while there is no edit/new form yet
    # assert_select "form[action=?][method=?]", final_wishes_path, "post" do

    # assert_select "input#final_wish_document_id[name=?]", "final_wish[document_id]"

    # assert_select "input#final_wish_user_id[name=?]", "final_wish[user_id]"

    # assert_select "input#final_wish_primary_contact_id[name=?]", "final_wish[primary_contact_id]"

    # assert_select "input#final_wish_notes[name=?]", "final_wish[notes]"

    # assert_select "input#final_wish_group[name=?]", "final_wish[group]"
    # end
  end
end
