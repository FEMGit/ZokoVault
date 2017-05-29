require 'rails_helper'

RSpec.describe Tutorial, type: :model do
  subject { build(:tutorial) }
  let!(:with_subtutorial) { build(:tutorial, subtutorials: [ build(:subtutorial) ]) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:number_of_pages) }
  it { should have_many :subtutorials }


  describe '#has_subtutorials?' do
    it 'has subtutorial should be true' do
      with_subtutorial.has_subtutorials?.should be true
    end

    it 'has no subtutorial should be false' do
      subject.has_subtutorials?.should be false
    end
  end
end
