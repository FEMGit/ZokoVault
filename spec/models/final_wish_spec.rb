require 'rails_helper'

RSpec.describe FinalWish, type: :model do
  let(:category_name) { "Final Wishes" }
  let!(:resource) { build(:final_wish) }

  it_behaves_like "category resource"
end
