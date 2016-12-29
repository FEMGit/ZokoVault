describe LifeAndDisabilityPunditPolicy do
  subject { described_class }

  let(:owner) { create(:user) }
  let(:resource) { create(:life_and_disability, user: owner) }

  it_behaves_like "shared resource"
  it_behaves_like "shared category" 
end
