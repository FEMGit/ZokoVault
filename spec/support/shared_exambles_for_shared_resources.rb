shared_examples "shared resource" do
  let(:non_owner) { create(:user) }
  let(:non_owner_contact) do
    non_owner.email = Faker::Internet.free_email
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

    context "owner's account shared with non-owner" do
      before do
        contact = Contact.find_by(emailaddress: non_owner.email)
        Share.create(contact: contact, shareable: owner)
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
        # user owner as a first parameter - cause we check
        # if current user has access for resource with owner = owner
        expect(subject).to permit(owner, resource)
      end
    end
  end
end