describe CategoryPolicy do
  subject { described_class }

  let(:admin) { create(:user, email: "admin_mail@zokuvault.com") }
  let(:nonadmin) { create(:user, email: "nonadmin@nokuvault.com") }
  let(:category) { create(:category) }

  permissions :index?, :destroy?, :new?, :create?, :update?, :edit?, :update?, :show? do
    it "permits access if user is admin" do
      expect(subject).to permit(admin, category)
    end

    it "denies access if user not admin" do
      expect(subject).not_to permit(nonadmin, category)
    end
  end
end
