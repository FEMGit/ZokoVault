class Discount
  attr_reader :id, :currency, :duration, :percent_off, :amount_off,
              :redeem_by, :times_redeemed, :valid
  
  def self.all
    stripe_objects = Stripe::Coupon.all.data
    stripe_objects.map { |object| new object }
  end
  
  def self.find(id)
    stripe_object = Stripe::Coupon.retrieve id
    new stripe_object
  end
  
  def self.create(params={})
    stripe_object = Stripe::Coupon.create defaults.merge(params)
    new stripe_object
  rescue Stripe::InvalidRequestError => e
    raise ArgumentError, e.message
  end
  
  def initialize(stripe_object)
    @id = stripe_object.id
    @currency = stripe_object.currency
    @duration = stripe_object.duration
    @percent_off = stripe_object.percent_off
    @amount_off = stripe_object.amount_off
    @redeem_by = stripe_object.redeem_by
    @times_redeemed = stripe_object.times_redeemed
    @valid = stripe_object.valid
  end
  
  def description
    if percent_off
      "#{percent_off}%"
    elsif amount_off
      "#{sprintf( "%0.02f", amount_off * 0.01)} #{currency}"
    end
  end
  
private

  def self.defaults
    { currency: "usd", duration: "once", max_redemptions: 1 }
  end
end
