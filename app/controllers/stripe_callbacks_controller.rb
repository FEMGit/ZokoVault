class StripeCallbacksController < ApplicationController
  before_action :authenticate_callback
  before_action :prep_request
  before_action :set_subscription, only: [:subscription_created]
  before_action :set_user
  
  def subscription_created
    @user.update(
      subscription_status: "paid",
      subscription_type: @subscription[:interval],
      paid_through: new_expiration_date
    )
    render json: {}, status: 200
  end
  
  def payment_success
    Payment.create(payment_params)
    render json: {}, status: 200
  end
  
  def payment_failure
    Payment.create(payment_params)
    render json: {}, status: 200
  end
  
  def subscription_expired
    @user.update(subscription_status: "unpaid")
    render json: {}, status: 200
  end
  
private
  
  def authenticate_callback
    render json: {}, status: 401 unless params[:key] == ENV["STRIPE_CALLBACK_TOKEN"]
  end
  
  def prep_request
    @request = JSON.parse(request.body.read)
  end
  
  def set_subscription
    @subscription = @request["data"]["object"]["items"]["data"][0]
  end
  
  def set_user
    if callback_type == "customer.subscription.created" || callback_type == "customer.subscription.deleted"
      stripe_customer = Stripe::Customer.retrieve(@request["data"]["object"]["customer"])
      @user = User.find_by(email: stripe_customer.email)
    elsif callback_type == "charge.succeeded" || callback_type == "charge.failed"
      charge = Stripe::Charge.retrieve @request["data"]["object"]["id"]
      @user = User.find_by(stripe_id: charge.customer)
    end
  end
  
  def new_expiration_date
    DateTime.strptime(@request["data"]["object"]["current_period_end"].to_s, '%s')
  end
  
  def payment_params
    payment_object = @request["data"]["object"]
    {
      user: @user,
      stripe_id: payment_object["id"],
      description: payment_object["description"],
      amount: payment_object["amount"],
      currency: payment_object["currency"],
      captured: payment_object["captured"]
    }
  end
  
  def callback_type
    @request["type"]
  end
end
