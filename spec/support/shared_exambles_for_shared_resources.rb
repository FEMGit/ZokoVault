shared_examples "shared resource" do
  let(:non_owner) { create(:user) }
  let(:non_owner_contact) { create(:contact, user: non_owner) }

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

    context "owner's account shared with non-owner" do
      before do
        owner.shares.create(contact: non_owner_contact, shareable: owner)
      end

      it "permits access if non_owner has account-level access" do
        expect(subject).to permit(non_owner, resource)
      end
    end

    context "resource is shared with non-owner" do
      before do
        owner.shares.create(contact: non_owner_contact, shareable: resource)
      end

      it "permits access if user has shared resource with contact" do
        expect(subject).to permit(non_owner, resource)
      end
    end
  end
end
