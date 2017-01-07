require 'rails_helper'

RSpec.describe PowerOfAttorney, type: :model do
  let(:category_name) { "Wills - Trusts - Legal" }
  let!(:resource) { build(:power_of_attorney) }

  it_behaves_like "category resource"
end
