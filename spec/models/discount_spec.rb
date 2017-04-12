require 'stripe_mock'

RSpec.describe Discount do
  before { StripeMock.start }
  after { StripeMock.stop }
  
  let(:attributes) do
    {
      id: Faker::Company.buzzword,
      duration: "once",
      percent_off: 10,
      redeem_by: (Date.today + 1.week).strftime('%s')
    }
  end
  
  describe "::all" do
    it "retrieves all created discounts from Stripe" do
      discount = Discount.create attributes
      expect(Discount.all[0].id).to eq discount.id
    end
  end
  
  describe "::find" do
    it "retrieves a Discount from Stripe by it's id" do
      original = Discount.create attributes
      retrieved = Discount.find original.id
      expect(retrieved).to be_a Discount
      expect(retrieved.id).to eq original.id
    end
  end
  
  describe "::create" do
    xit "creates a Stripe::Coupon object from a hash of params" do
      expect(Stripe::Coupon).to receive(:create).exactly(1).times
      Discount.create attributes
    end
    
    it "returns a Discount instance" do
      discount = Discount.create attributes
      expect(discount).to be_a Discount
    end
    
    xit "enforces percent_off or amount_of as a required argument" do
      expect {
        Discount.create currency: "usd"
      }.to raise_error ArgumentError
    end
  end
  
  describe "#initialize" do
    let(:stripe_object) { Stripe::Coupon.create attributes }
    
    it "creates a Discount instance from a stripe object" do
      discount = Discount.new stripe_object
      expect(discount).to be_a(Discount)
      expect(discount.id).to eq attributes[:id]
      expect(discount.currency).to eq attributes[:currency]
      expect(discount.duration).to eq attributes[:duration]
      expect(discount.percent_off).to eq attributes[:percent_off]
      expect(discount.amount_off).to eq attributes[:amount_off]
      expect(discount.redeem_by).to eq attributes[:redeem_by]
      expect(discount.times_redeemed).to eq 0
      expect(discount.valid).to eq true
    end
  end
  
  describe "#description" do
    it "returns a description for percent_off Discounts" do
      discount = Discount.create attributes
      expect(discount.description).to eq("10%")
    end
    
    it "returns a description for amount_off Discounts" do
      new_attribues = {amount_off: 10_00, percent_off: nil}
      discount = Discount.create attributes.merge(new_attribues)
      expect(discount.description).to eq("10.00 usd")
    end
  end
end
