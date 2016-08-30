require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the SharesHelper. For example:
#
# describe SharesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe FoldersHelper, type: :helper do
  describe "#path_helper" do
    context "is a category" do
      subject  { Category.new }
      before { subject.id = 1 }

      it "returns a category path" do
        expect(path_helper(subject)).to eq(category_path(subject))
      end
    end

    context "is a folder" do
      subject  { Folder.new }
      before { subject.id = 2 }

      it "returns a folder path" do
        expect(path_helper(subject)).to eq(new_folder_path(subject))
      end
    end
  end
end
