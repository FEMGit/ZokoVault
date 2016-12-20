describe TaxPolicy do
  subject { described_class }

  let(:owner) { create(:user) }
  let(:resource) { create(:tax, user: owner) }

  it_behaves_like "shared resource"
end
