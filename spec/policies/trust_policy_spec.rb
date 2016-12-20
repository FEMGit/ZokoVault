describe TrustPolicy do
  subject { described_class }

  let(:owner) { create(:user) }
  let(:resource) { create(:trust, user: owner) }

  it_behaves_like "shared resource"
end
