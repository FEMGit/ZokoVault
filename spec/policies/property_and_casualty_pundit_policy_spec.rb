describe PropertyAndCasualtyPunditPolicy do
  subject { described_class }

  let(:owner) { create(:user) }
  let(:resource) { create(:property_and_casualty, user: owner) }

  it_behaves_like "shared resource"
end
