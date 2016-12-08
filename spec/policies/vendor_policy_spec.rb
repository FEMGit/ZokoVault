describe VendorPolicy do
  subject { described_class }

  let(:owner) { create(:user) }
  let(:resource) { create(:vendor, user: owner) }

  it_behaves_like "shared resource"
end
