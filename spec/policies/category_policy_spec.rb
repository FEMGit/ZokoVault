describe CategoryPolicy do
  subject { described_class }

  let(:owner) { create(:user) }
  let(:resource) { create(:category, user: owner) }

  it_behaves_like "shared resource"
end
