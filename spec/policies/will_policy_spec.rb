describe WillPolicy do
  subject { described_class }

  let(:owner) { create(:user) }
  let(:resource) { create(:will, user: owner) }

  it_behaves_like "shared resource"
  it_behaves_like "shared category" 
end
