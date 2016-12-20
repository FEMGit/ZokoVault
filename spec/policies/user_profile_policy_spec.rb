describe UserProfilePolicy do
  subject { described_class }

  let(:owner) { create(:user) }
  let(:resource) { create(:user_profile, user: owner) }

  it_behaves_like "shared resource"
end
