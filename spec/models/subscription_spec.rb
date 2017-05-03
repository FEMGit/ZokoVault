RSpec.describe StripeSubscription do
  let(:stripe_helper) { StripeMock.create_test_helper }

  let!(:plan) do
    stripe_helper.create_plan(
      id: "test_plan",
      amount: 100,
      name: "test-monthly-zoku-plan"
    )
  end

  let(:user) { create(:user) }
  let(:valid_params) do
    {
      stripe_token: stripe_helper.generate_card_token,
      user_email: user.email,
      plan_id: plan.id
    }
  end

  describe "::plans" do
    it "retrieves a list of all StripeSubscription plans" do
      plans = StripeSubscription.plans
      expect(plans).to eq([plan])
    end
  end

  describe "::create" do
    before :each do
      @subscription = StripeSubscription.create valid_params
    end
    it "creates a Stripe customer from a token and a user email" do
      expect {
        Stripe::Customer.retrieve(@subscription.id)
      }.to_not raise_error(Stripe::InvalidRequestError)
    end

    it "creates a Stripe subscription for the customer object" do
      cust_object = Stripe::Customer.retrieve(@subscription.id)
      expect(cust_object.subscriptions.data).to_not be_empty
    end

    it "initializes a StripeSubscription object" do
      expect(@subscription).to be_a(StripeSubscription)
    end
  end

  describe "::find" do
    before :each do
      @id = StripeSubscription.create(valid_params).id
    end

    it "initializes a StripeSubscription object from a stripe_id" do
      subscription = StripeSubscription.find @id
      expect(subscription).to be_a(StripeSubscription)
    end
  end

  describe "#initialize" do
    before :each do
      @subscription = StripeSubscription.create valid_params
      @cust_object = Stripe::Customer.retrieve @subscription.id
    end

    it "creates a StripeSubscription with various attributes" do
      expect(@subscription.id).to eq(@cust_object.id)
      plan_data = @cust_object.subscriptions.data[0].plan
      expect(@subscription.plan_id).to eq(plan_data.id)
      expect(@subscription.user_email).to eq(@cust_object.email)
      expect(@subscription.interval).to eq(plan_data.interval)
    end

    it "creates a payment hash for the subscription" do
      payment_hash = @subscription.payment
      payment_data = @cust_object.sources.select { |p|
        @cust_object.default_source == p.id
      }[0]
      expect(payment_hash[:funding]).to eq(payment_data.funding)
      expect(payment_hash[:last4]).to eq(payment_data.last4)
      expect(payment_hash[:brand]).to eq(payment_data.brand)
      expect(payment_hash[:country]).to eq(payment_data.country)
      expect(payment_hash[:exp_month]).to eq(payment_data.exp_month)
      expect(payment_hash[:exp_year]).to eq(payment_data.exp_year)
      expect(payment_hash[:cvc_check]).to eq(payment_data.cvc_check)
      expect(payment_hash[:fingerprint]).to eq(payment_data.fingerprint)
    end
  end

  describe "#refresh!" do
    it "resets the StripeSubscription to equal it's state on Stripe's server" do
      subscription = StripeSubscription.create valid_params
      stripe_cust = Stripe::Customer.retrieve subscription.id
      stripe_cust.email = "new_email@zokuvault.com"
      stripe_cust.save
      expect(subscription.user_email).to_not eq(stripe_cust.email)
      subscription.refresh!
      expect(subscription.user_email).to eq(stripe_cust.email)
    end
  end

  xdescribe "#update" do
    before :each do
      @subscription = StripeSubscription.create valid_params
      @cust_object = Stripe::Customer.retrieve @subscription.id
    end

    it "updates the user's payment" do
      alt_token = stripe_helper.generate_card_token(last4: "1881")
      @subscription.update(stripe_token: alt_token)
      @subscription.refresh!
      expect(@subscription.payment[:id])
        .to eq(Stripe::Token.retrieve(alt_token).card.id)
    end

    context "updating the auto resubscribe status" do
      xit "updates on Stripe" do
        @subscription.update(auto_resubscribe: false)
        cust_object = Stripe::Customer.retrieve @subscription.id
        expect(cust_object.subscriptions.data[0].cancel_at_period_end)
          .to eq(true)
        # @subscription.update(auto_resubscribe: true)
        # cust_object = Stripe::Customer.retrieve @subscription.id
        # expect(cust_object.subscriptions.data[0].cancel_at_period_end)
        #   .to eq(false)
      end

      it "updates for the User" do
        @subscription.update(auto_resubscribe: false)
        user.reload
        expect(user.auto_resubscribe).to eq(false)
        @subscription.update(auto_resubscribe: true)
        user.reload
        expect(user.auto_resubscribe).to eq(true)
      end
    end

    it "updates the user's plan" do
      new_plan = stripe_helper.create_plan(
        id: "test_plan2",
        amount: 100,
        name: "test-annual-zoku-plan"
      )
      @subscription.update(plan_id: new_plan.id)
      cust_object = Stripe::Customer.retrieve @subscription.id
      expect(@subscription.plan_id).to eq(new_plan.id)
      expect(cust_object.subscriptions.data[0].plan.id).to eq(new_plan.id)
    end
  end

  describe "#user" do
    it "finds the user associated with this StripeSubscription" do
      params = valid_params.merge(user_email: user.email)
      subscription = StripeSubscription.create params
      expect(subscription.user).to eq(user)
    end
  end

  describe "#payments" do
    it "delegates to the User#payments method" do
      subscription = StripeSubscription.create valid_params
      expect(subscription.payments).to eq(user.payments)
    end
  end

  describe "#status" do
    it "delegates to the User#subscription method" do
      subscription = StripeSubscription.create valid_params
      expect(subscription.status).to eq(user.subscription_status)
    end
  end

  describe "#apply_discount" do
    before :each do
      @subscription = StripeSubscription.create valid_params
      @discount = Discount.create(
        id: Faker::Company.buzzword,
        currency: "usd",
        duration: "forever",
        percent_off: 10,
        redeem_by: (Date.today + 1.week).strftime('%s')
      )
      @subscription.apply_discount @discount
    end

    it "adds a discount to the Stripe subscription" do
      stripe_object = Stripe::Customer.retrieve(user.stripe_id).subscriptions.data[0]
      expect(stripe_object.discount.coupon.id).to eq @discount.id
    end
  end
end
