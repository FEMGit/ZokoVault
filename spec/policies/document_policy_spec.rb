describe DocumentPolicy do
  subject { described_class }

  let(:owner) { create(:user) }
  let(:resource) { create(:document, user: owner) }

  it_behaves_like "shared resource"
end
