describe FinalWishPolicy do
  subject { described_class }

  let(:owner) { create(:user) }
  let(:resource) { create(:final_wish, user: owner) }

  it_behaves_like "shared resource"
  it_behaves_like "shared category" 
end
