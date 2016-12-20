describe UploadPolicy do
  subject { described_class }

  let(:owner) { create(:user) }
  let(:resource) { create(:upload, user: owner) }

  it_behaves_like "shared resource"
end
