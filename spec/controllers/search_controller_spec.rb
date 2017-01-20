require 'rails_helper'

RSpec.describe SearchController, type: :controller do


  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET #index" do
    context "when querystring is passed" do
      before do
        allow_any_instance_of(UserResourceGatherer).to receive(:all_resources)
        allow(ResourceSearcher)
          .to receive(:new) { double(:search => [:results])}
      end

      it "assigns @search_results" do
        get :index, { q: "foo" }, session: {}
        expect(assigns(:search_results)).to be_present
        expect(assigns(:paginated_results)).to be_present
      end
    end

    context "when querystring is not passed" do
      it "doesn't assign @search_results" do
        get :index, {}, session: {}
        expect(assigns(:search_results)).to be_blank
        expect(assigns(:paginated_results)).to be_blank
      end
    end
  end
end
