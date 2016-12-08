describe HealthPunditPolicy do
  subject { described_class }

  let(:owner) { create(:user) }
  let(:resource) { create(:health, user: owner) }

  it_behaves_like "shared resource"
end
