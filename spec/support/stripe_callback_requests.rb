module StripeCallbackRequests
  class << self
    def subscription_created
      {
        "created" => 1326853478,
        "livemode" => false,
        "id" => "evt_00000000000000",
        "type" => "customer.subscription.created",
        "object" => "event",
        "pending_webhooks" => 1,
        "api_version" => "2017-01-27",
        "data" => {
          "object" => {
            "id" => "sub_00000000000000",
            "object" => "subscription",
            "cancel_at_period_end" => false,
            "created" => 1487113854,
            "current_period_end" => 1518649854,
            "current_period_start" => 1487113854,
            "customer" => "cus_00000000000000",
            "items" => {
              "object" => "list",
              "data" => [
                {
                  "id" => "si_19nFRiLux2fkZmyyb1HuFkGM",
                  "object" => "subscription_item",
                  "created" => 1487113855,
                  "plan" => {
                    "id" => "4c945b92-92dc-4df3-af75-002ac0e5edd0",
                    "object" => "plan",
                    "amount" => 30000,
                    "created" => 1487050615,
                    "currency" => "usd",
                    "interval" => "year",
                    "interval_count" => 1,
                    "livemode" => false,
                    "name" => "test-annual-zoku-plan",
                    "statement_descriptor" => "zoku sub payment"
                  },
                  "quantity" => 1
                }
              ],
              "has_more" => false,
              "total_count" => 1,
              "url" => "/v1/subscription_items?subscription=sub_A7UQBCuNSLPyFg"
            },
            "livemode" => false,
            "plan" => {
              "id" => "4c945b92-92dc-4df3-af75-002ac0e5edd0_00000000000000",
              "object" => "plan",
              "amount" => 30000,
              "created" => 1487050615,
              "currency" => "usd",
              "interval" => "year",
              "interval_count" => 1,
              "livemode" => false,
              "name" => "test-annual-zoku-plan",
              "statement_descriptor" => "zoku sub payment"
            },
            "quantity" => 1,
            "start" => 1487113854,
            "status" => "active"
          }
        }
      }
    end
    
    def payment_success
      {
        "created" => 1326853478,
        "livemode" => false,
        "id" => "evt_00000000000000",
        "type" => "charge.succeeded",
        "object" => "event",
        "pending_webhooks" => 1,
        "api_version" => "2017-01-27",
        "data" => {
          "object" => {
            "id" => "ch_00000000000000",
            "object" => "charge",
            "amount" => 100,
            "amount_refunded" => 0,
            "balance_transaction" => "txn_00000000000000",
            "captured" => true,
            "created" => 1487113623,
            "currency" => "usd",
            "description" => "My First Test Charge (created for API docs)",
            "livemode" => false,
            "paid" => true,
            "refunded" => false,
            "refunds" => {
              "object" => "list",
              "has_more" => false,
              "total_count" => 0,
              "url" => "/v1/charges/ch_19nFNzLux2fkZmyyvDXK9qcG/refunds"
            },
            "source" => {
              "id" => "card_00000000000000",
              "object" => "card",
              "brand" => "Visa",
              "country" => "US",
              "exp_month" => 8,
              "exp_year" => 2018,
              "funding" => "credit",
              "last4" => "4242"
            },
            "status" => "succeeded"
          }
        }
      }
    end
    
    def payment_failure
      {
        "created" => 1326853478,
        "livemode" => false,
        "id" => "evt_00000000000000",
        "type" => "charge.failed",
        "object" => "event",
        "pending_webhooks" => 1,
        "api_version" => "2017-01-27",
        "data" => {
          "object" => {
            "id" => "ch_00000000000000",
            "object" => "charge",
            "amount" => 30000,
            "amount_refunded" => 0,
            "balance_transaction" => "txn_00000000000000",
            "captured" => true,
            "created" => 1487133650,
            "currency" => "usd",
            "customer" => "cus_00000000000000",
            "invoice" => "in_00000000000000",
            "livemode" => false,
            "outcome" => {
              "network_status" => "approved_by_network",
              "risk_level" => "normal",
              "seller_message" => "Payment complete.",
              "type" => "authorized"
            },
            "paid" => false,
            "refunded" => false,
            "refunds" => {
              "object" => "list",
              "has_more" => false,
              "total_count" => 0,
              "url" => "/v1/charges/ch_19nKb0Lux2fkZmyyNz8PC6ii/refunds"
            },
            "source" => {
              "id" => "card_00000000000000",
              "object" => "card",
              "brand" => "Visa",
              "country" => "US",
              "customer" => "cus_00000000000000",
              "cvc_check" => "pass",
              "exp_month" => 11,
              "exp_year" => 2019,
              "funding" => "credit",
              "last4" => "4242"
            },
            "statement_descriptor" => "zoku sub payment",
            "status" => "succeeded"
          }
        }
      }
    end
    
    def subscription_expired
      {
        "created" => 1326853478,
        "livemode" => false,
        "id" => "evt_00000000000000",
        "type" => "customer.subscription.deleted",
        "object" => "event",
        "pending_webhooks" => 1,
        "api_version" => "2017-01-27",
        "data" => {
          "object" => {
            "id" => "sub_00000000000000",
            "object" => "subscription",
            "cancel_at_period_end" => false,
            "created" => 1487133650,
            "current_period_end" => 1518669650,
            "current_period_start" => 1487133650,
            "customer" => "cus_00000000000000",
            "ended_at" => 1487141609,
            "items" => {
              "object" => "list",
              "data" => [
                {
                  "id" => "si_19nKb0Lux2fkZmyy1N3RouHn",
                  "object" => "subscription_item",
                  "created" => 1487133651,
                  "plan" => {
                    "id" => "4c945b92-92dc-4df3-af75-002ac0e5edd0",
                    "object" => "plan",
                    "amount" => 30000,
                    "created" => 1487050615,
                    "currency" => "usd",
                    "interval" => "year",
                    "interval_count" => 1,
                    "livemode" => false,
                    "name" => "test-annual-zoku-plan",
                    "statement_descriptor" => "zoku sub payment"
                  },
                  "quantity" => 1
                }
              ],
              "has_more" => false,
              "total_count" => 1,
              "url" => "/v1/subscription_items?subscription=sub_A7Zk482DjWTFbV"
            },
            "livemode" => false,
            "plan" => {
              "id" => "4c945b92-92dc-4df3-af75-002ac0e5edd0_00000000000000",
              "object" => "plan",
              "amount" => 30000,
              "created" => 1487050615,
              "currency" => "usd",
              "interval" => "year",
              "interval_count" => 1,
              "livemode" => false,
              "name" => "test-annual-zoku-plan",
              "statement_descriptor" => "zoku sub payment"
            },
            "quantity" => 1,
            "start" => 1487133650,
            "status" => "canceled"
          }
        }
      }
    end
  end
end
