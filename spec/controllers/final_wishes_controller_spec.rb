require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe FinalWishesController, type: :controller do

  let!(:user) { create :user }
  let!(:final_wish_info) do
    create :final_wish_info,
    user_id: user.id,
    group: Rails.application.config.x.categories["Final Wishes"]["groups"].sample["label"]
  end
  let!(:document) do
    create :document, user_id: user.id, category: "Final Wishes", group: final_wish_info.group
  end

  # This should return the minimal set of attributes required to create a valid
  # FinalWish. As you add validations to FinalWish, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { skip("Add a hash of attributes valid for your model") }

  let(:invalid_attributes) { skip("Add a hash of attributes invalid for your model") }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # FinalWishesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "assigns all final_wish_infos as @final_wishes" do
      get :index, {}, session: valid_session
      expect(assigns(:final_wishes)).to eq([final_wish_info])
    end
  end

  describe "GET #show" do
    it "assigns @final_wish's group to @group" do
      get :show, {id: final_wish_info.to_param}, session: valid_session
      expect(assigns(:group)["label"]).to eq(final_wish_info.group)
    end

    it "assigns user's final wish docs in the appropriate group to @group_documents" do
      get :show, {user: user, id: final_wish_info.to_param}, session: valid_session
      expect(assigns(:group_documents)).to eq([document])
    end
  end

  # Disable while new Final wish not creating
  # describe "GET #new" do
  #  it "assigns a new final_wish as @final_wish" do
  #    get :new, params: {}, session: valid_session
  #    expect(assigns(:final_wish)).to be_a(FinalWish)
  #  end
  # end

  describe "GET #edit" do
    it "assigns @final_wish's group to @group" do
      get :edit, {id: final_wish_info.to_param}, session: valid_session
      expect(assigns(:group)["label"]).to eq(final_wish_info.group)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new FinalWish" do
        expect { post :create, params: { final_wish: valid_attributes }, session: valid_session }
          .to change(FinalWish, :count).by(1)
      end

      it "assigns a newly created final_wish as @final_wish" do
        post :create, params: {final_wish: valid_attributes}, session: valid_session
        expect(assigns(:final_wish)).to be_a(FinalWish)
        expect(assigns(:final_wish)).to be_persisted
      end

      it "redirects to the created final_wish" do
        post :create, params: {final_wish: valid_attributes}, session: valid_session
        expect(response).to redirect_to(FinalWish.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved final_wish as @final_wish" do
        post :create, params: {final_wish: invalid_attributes}, session: valid_session
        expect(assigns(:final_wish)).to be_a_new(FinalWish)
      end

      it "re-renders the 'new' template" do
        post :create, params: {final_wish: invalid_attributes}, session: valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { skip("Add a hash of attributes valid for your model") }

      it "updates the requested final_wish" do
        final_wish = FinalWish.create! valid_attributes
        put :update, params: {id: final_wish.to_param, final_wish: new_attributes}, session: valid_session
        final_wish.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested final_wish as @final_wish" do
        final_wish = FinalWish.create! valid_attributes
        put :update, params: {id: final_wish.to_param, final_wish: valid_attributes}, session: valid_session
        expect(assigns(:final_wish)).to eq(final_wish)
      end

      it "redirects to the final_wish" do
        final_wish = FinalWish.create! valid_attributes
        put :update, params: {id: final_wish.to_param, final_wish: valid_attributes}, session: valid_session
        expect(response).to redirect_to(final_wish)
      end
    end

    context "with invalid params" do
      it "assigns the final_wish as @final_wish" do
        final_wish = FinalWish.create! valid_attributes
        put :update, params: {id: final_wish.to_param, final_wish: invalid_attributes}, session: valid_session
        expect(assigns(:final_wish)).to eq(final_wish)
      end

      it "re-renders the 'edit' template" do
        final_wish = FinalWish.create! valid_attributes
        put :update, params: {id: final_wish.to_param, final_wish: invalid_attributes}, session: valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested final_wish" do
      final_wish = FinalWish.create! valid_attributes
      expect { delete :destroy, params: {id: final_wish.to_param}, session: valid_session }
        .to change(FinalWish, :count).by(-1)
    end

    it "redirects to the final_wishes list" do
      final_wish = FinalWish.create! valid_attributes
      delete :destroy, params: {id: final_wish.to_param}, session: valid_session
      expect(response).to redirect_to(final_wishes_url)
    end
  end

end
