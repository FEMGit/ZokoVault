shared_examples "shared category" do
  let(:non_owner) { create(:user) }
  let(:non_owner_contact) do
    non_owner.email = Faker::Internet.free_email
    create(:contact, emailaddress: non_owner.email, user: non_owner)
  end

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
        expect(resource.category).to be
        owner.shares.create(contact: non_owner_contact, shareable: resource.category)
      end

      it "permits access if user has shared resource with contact" do
        expect(subject).to permit(non_owner, resource)
      end
    end
  end
end
