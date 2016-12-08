describe FolderPolicy do
  subject { described_class }

  let(:owner) { create(:user) }
  let(:resource) { create(:folder, user: owner) }

  it_behaves_like "shared resource"
end
