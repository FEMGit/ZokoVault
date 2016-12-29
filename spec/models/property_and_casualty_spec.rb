require 'rails_helper'

RSpec.describe PropertyAndCasualty, type: :model do
  let(:category_name) { "Insurance" }
  let!(:resource) { build(:property_and_casualty) }

  it_behaves_like "category resource"
end
