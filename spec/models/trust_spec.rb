require 'rails_helper'

RSpec.describe Trust, type: :model do
  let(:category_name) { "Wills - Trusts - Legal" }
  let!(:resource) { build(:trust) }

  it_behaves_like "category resource"
end
