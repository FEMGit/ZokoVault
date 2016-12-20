describe SharePolicy do
  subject { described_class }

  let(:owner) { create(:user) }
  let(:resource) { create(:share, user: owner) }

  let(:non_owner) { create(:user) }
  let(:non_owner_contact) do
    create(:contact, emailaddress: non_owner.email, user: non_owner)
  end

  permissions :index?, :destroy?, :new?, :create? do
    context "resource is not shared" do
      it "denies access if user not the owner" do
        expect(subject).not_to permit(non_owner, resource)
      end

      it "permits access if user is owner" do
        expect(subject).to permit(owner, resource)
      end
    end
  end

  permissions :update?, :edit?, :update?, :show? do
    context "resource is not shared" do
      it "denies access if user not the owner" do
        expect(subject).not_to permit(non_owner, resource)
      end

      it "permits access if user is owner" do
        expect(subject).to permit(owner, resource)
      end
    end

    context "resource is connected to non-owner contact" do
      let(:resource) { create(:share, user: owner, contact: non_owner_contact) }

      it "permits access if user has shared resource with contact" do
        expect(subject).to permit(non_owner, resource)
      end
    end
  end
end
