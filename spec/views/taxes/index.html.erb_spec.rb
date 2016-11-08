require 'rails_helper'

RSpec.describe "taxes/index", type: :view do
  before(:each) do
    assign(:taxes, [
      Tax.create!(
        :document_id => "",
        :tax_preparer_id => "",
        :notes => "",
        :user_id => "",
        :tax_year => 2
      ),
      Tax.create!(
        :document_id => "",
        :tax_preparer_id => "",
        :notes => "",
        :user_id => "",
        :tax_year => 2
      )
    ])
  end
end
