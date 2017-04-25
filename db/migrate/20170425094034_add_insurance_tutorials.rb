class AddInsuranceTutorials < ActiveRecord::Migration
  def change
    [{ name: 'I have Life or disability Insurance', page: 'insurance/life_and_disability'},
     { name: 'I have Property Insurance', page: 'insurance/property' },
     { name: 'I have Health Insurance', page: 'insurance/health' }].each do |tutorial|
      Tutorial.create(name: tutorial[:name], category_id: Category.fetch('insurance').try(:id), relative_page_path: 'tutorials/' + tutorial[:page])
    end
  end
end
