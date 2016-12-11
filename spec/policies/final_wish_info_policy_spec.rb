describe FinalWishInfoPolicy do
  subject { described_class }

  let(:owner) { create(:user) }
  let(:resource) { create(:final_wish_info, user: owner) }

  it_behaves_like "shared resource"
end
