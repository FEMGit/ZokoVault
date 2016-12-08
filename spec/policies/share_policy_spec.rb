describe SharePolicy do
  subject { described_class }

  let(:owner) { create(:user) }
  let(:resource) { create(:share, user: owner) }

  it_behaves_like "shared resource"
end
