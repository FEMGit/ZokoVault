shared_examples "shared category" do
  let(:non_owner) { create(:user) }

  permissions :index?, :destroy?, :new?, :create? do
    context "category is not shared" do
      it "denies access if user not the owner" do
        expect(subject).not_to permit(non_owner, resource)
      end

      it "permits access if user is owner" do
        expect(subject).to permit(owner, resource)
      end
    end
  end

  permissions :update?, :edit?, :update?, :show? do
    context "category is not shared" do
      it "denies access if user not the owner" do
        expect(subject).not_to permit(non_owner, resource)
      end

      it "permits access if user is owner" do
        expect(subject).to permit(owner, resource)
      end
    end

    context "category is shared with non-owner" do
      before do
        non_owner_contact = Contact.find_by(emailaddress: non_owner.email)
        expect(resource.category).to be
        owner.shares.create(contact: non_owner_contact, shareable: resource.category)
      end

      it "permits access if user has shared resource with contact" do
        # user owner as a first parameter - cause we check
        # if current user has access for resource with owner = owner
        expect(subject).to permit(owner, resource)
      end
    end
  end
end
