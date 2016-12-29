shared_examples "category resource" do
  context "on save" do
    it "sets category assocation" do
      resource.save
      expect(resource.category).to eq Category.find_by(name: category_name)
    end
  end
end

