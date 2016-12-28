require 'rails_helper'

RSpec.describe TaxesController, type: :controller do

  let(:user) { create(:user) }
  let(:valid_attributes) { { year: 2007 } }

  let(:invalid_attributes) do
    skip("No validations on the model associated with this controller")
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # TaxesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before { sign_in user }

  describe "GET #index" do
    it "assigns all taxes for the resource_owner as @taxes" do
      tax = create(:tax_year_info, user_id: user.id)
      get :index, {}, valid_session
      expect(assigns(:taxes)).to eq([tax])
    end
  end

  describe "GET #show" do
    it "assigns the requested tax as @tax_year_info" do
      tax = create(:tax_year_info, user_id: user.id)
      get :show, { id: tax.to_param }, valid_session
      expect(assigns(:tax)).to eq(tax)
    end
  end

   describe "GET #new" do
     context "user has taxes for this year" do
       it "redirects to the edit_tax path" do
         tax = create(:tax_year_info, user_id: user.id)
         get :new, { year: tax.year }, valid_session
         expect(response).to redirect_to(edit_tax_path(tax))
       end
     end

     context "user has no taxes for this year" do
       it "assigns a new tax as @tax_year" do
         get :new, { year: 1979 }, valid_session
         expect(assigns(:tax_year)).to be_a_new(TaxYearInfo)
       end
     end
   end

  describe "GET #edit" do
    it "assigns the requested tax as @tax_year" do
      tax = create(:tax_year_info, user_id: user.id)
      get :edit, { id: tax.to_param }, valid_session
      expect(assigns(:tax_year)).to eq(tax)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Tax" do
        expect { post :create, { tax_year_info: valid_attributes }, valid_session }
          .to change(TaxYearInfo, :count).by(1)
      end

      it "assigns a newly created tax as @tax_year" do
        post :create, { tax_year_info: valid_attributes }, valid_session
        expect(assigns(:tax_year)).to be_a(TaxYearInfo)
        expect(assigns(:tax_year)).to be_persisted
      end

      it "redirects to the created tax" do
        post :create, { tax_year_info: valid_attributes }, valid_session
        expect(response).to redirect_to(Tax.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved tax as @tax" do
        post :create, { tax_year_info: invalid_attributes }, valid_session
        expect(assigns(:tax)).to be_a_new(Tax)
      end

      it "re-renders the 'new' template" do
        post :create, { tax_year_info: invalid_attributes }, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    let(:new_year) { 1871 }
    let(:new_valid_attributes) do
      valid_attributes.merge({ year: new_year })
    end
    let(:new_invalid_attributes) do
      skip("No validations on the model associated with this controller")
    end

    context "with valid params" do
      it "updates the requested tax" do
        tax = create(:tax_year_info, user_id: user.id)
        put :update, { id: tax.to_param,  tax_year_info: new_valid_attributes }, valid_session
        tax.reload
        expect(tax.year).to eq(new_year)
      end

      it "assigns the requested tax as @tax_year" do
        tax = create(:tax_year_info, user_id: user.id)
        put :update, {id: tax.to_param,  tax_year_info: new_valid_attributes }, valid_session
        expect(assigns(:tax)).to eq(tax)
      end

      it "redirects to the taxes index" do
        tax = create(:tax_year_info, user_id: user.id)
        put :update, { id: tax.to_param,  tax_year_info: new_valid_attributes }, valid_session
        expect(response).to redirect_to(taxes_path)
      end
    end

    context "with invalid params" do
      it "assigns the tax as @tax" do
        tax = create(:tax_year_info, user_id: user.id)
        put :update, { id: tax.to_param,  tax_year_info: new_invalid_attributes }, valid_session
        expect(assigns(:tax)).to eq(tax)
      end

      it "re-renders the 'edit' template" do
        tax = create(:tax_year_info, user_id: user.id)
        put :update, { id: tax.to_param,  tax_year_info: new_invalid_attributes }, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    before :each do
      request.env["HTTP_REFERER"] = "/taxes"
    end

    it "destroys the requested tax" do
      tax = create(:tax, user_id: user.id)
      expect { delete :destroy, { id: tax.to_param }, valid_session }
        .to change(Tax, :count).by(-1)
    end

    it "redirects to the taxes list" do
      tax = create(:tax, user_id: user.id)
      delete :destroy, { id: tax.to_param }, valid_session
      expect(response).to redirect_to(taxes_url)
    end
  end

end
