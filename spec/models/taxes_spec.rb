require 'rails_helper'

RSpec.describe Tax, type: :model do
  let(:category_name) { "Taxes" }
  let!(:resource) { build(:tax) }

  it_behaves_like "category resource"
end
