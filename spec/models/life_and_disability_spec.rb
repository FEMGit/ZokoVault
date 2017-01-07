require 'rails_helper'

RSpec.describe LifeAndDisability, type: :model do
  let(:category_name) { "Insurance" }
  let!(:resource) { build(:life_and_disability) }

  it_behaves_like "category resource"
end
