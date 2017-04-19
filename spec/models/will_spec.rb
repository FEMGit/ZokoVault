require 'rails_helper'

RSpec.describe Will, type: :model do
  let(:category_name) { "Wills - POA" }
  let!(:resource) { build(:will) }

  it_behaves_like "category resource"
end
