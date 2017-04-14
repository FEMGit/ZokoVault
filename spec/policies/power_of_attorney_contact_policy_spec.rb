describe PowerOfAttorneyContactPolicy do
  subject { described_class }

  let(:owner) { create(:user) }
  let(:resource) { create(:power_of_attorney_contact, user: owner) }

  it_behaves_like "shared resource"
  it_behaves_like "shared category" 
end
