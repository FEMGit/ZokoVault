require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ZokuVault
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths << Rails.root.join('app', 'services')
    config.x.WtlCategory = "Wills - Trusts - Legal"
    config.x.InsuranceCategory = "Insurance"
    config.x.ContactCategory = "Contact"
    config.x.TaxCategory = "Taxes"
    config.x.FinalWishesCategory = "Final Wishes"

    config.x.categories = {
      config.x.WtlCategory => {
        "label" => "Wills - Trusts - Legal",
        "groups" => [
          {"value" => "will",
            "label" => "Will"
          },
          {"value" => "trust",
            "label" => "Trust"
          },
          {"value" => "attorney",
            "label" => "Legal"
          }
        ]
      },
      config.x.InsuranceCategory => {
        "label" => "Insurance",
        "groups" => [
          {"value" => "life",
            "label" => "Life & Disability"
          },
          {"value" => "property",
            "label" => "Property & Casualty"
          },
          {"value" => "health",
            "label" => "Health"
          }
        ]
      },
      config.x.TaxCategory => {
        "label" => "Taxes",
        "groups" => [
          {"value" => "2016",
            "label" => "2016"
          },
          {"value" => "2015",
            "label" => "2015"
          },
          {"value" => "2014",
            "label" => "2014"
          },
          {"value" => "2013",
            "label" => "2013"
          },
          {"value" => "2012",
            "label" => "2012"
          },
          {"value" => "2011",
            "label" => "2011"
          },
          {"value" => "2010",
            "label" => "2010"
          }
        ]
      },
      config.x.FinalWishesCategory => {
        "label" => "Final Wishes",
        "groups" => [
          {"value" => "Burial",
            "label" => "Burial"
          },
          {"value" => "Charity",
            "label" => "Charity"
          },
          {"value" => "Cremation",
            "label" => "Cremation"
          },
          {"value" => "Ethical Will",
            "label" => "Ethical Will"
          },
          {"value" => "Funeral / Memorial",
            "label" => "Funeral / Memorial"
          },
          {"value" => "Items to Destroy",
            "label" => "Items to Destroy"
          },
          {"value" => "Miscellaneous",
            "label" => "Miscellaneous"
          },
          {"value" => "Obituary",
            "label" => "Obituary"
          },
          {"value" => "Organ Donor",
            "label" => "Organ Donor"
          },
          {"value" => "Pet Care",
            "label" => "Pet Care"
          },
          {"value" => "Veterans",
            "label" => "Veterans"
          }
        ]
      },
      config.x.ContactCategory => {
        "label" => "Contact",
        "groups" => [
        ]
      }
    }    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
  end
end
