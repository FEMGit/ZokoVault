describe ContactPolicy do
  subject { described_class }

  let(:owner) { create(:user) }
  let(:resource) { create(:contact, user: owner) }

  it_behaves_like "shared resource"
end
