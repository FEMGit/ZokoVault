source 'https://rubygems.org'
ruby "2.3.1"
gem 'json', github: 'flori/json', branch: 'v1.8'

gem 'rails', '4.2.7.1'

gem 'pg'
gem "rails_12factor", group: :production

# Authentication
gem 'devise', '>= 4.2.0'

# Authorization
gem "pundit"

# Pdf Generation
gem 'pdfkit'
gem 'wkhtmltopdf-binary'
gem 'wkhtmltopdf-heroku'

# 'To store old user passwords'
gem 'devise_security_extension'

gem 'acts_as_tree'

# Email Validation
gem 'validates_email_format_of'

# Web server
gem 'puma'

# Delayed job need for Puma web server
gem 'delayed_job_active_record'

# Abort long requests
gem 'rack-timeout'

# Block and throttle abusive requests
gem 'rack-attack'

# Scheduler
gem 'rufus-scheduler'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# JS runtime
gem 'execjs'
gem 'therubyracer'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'

# Datatable for tables sorting
gem 'ajax-datatables-rails'
gem 'jquery-datatables-rails'
gem 'maskedinput-rails'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Highcharts
gem 'highcharts-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Design and grid tools
gem 'bourbon'
gem 'neat'

# File Up/download tools
gem 'aws-sdk', '~> 2'
gem 'carrierwave', '0.10.0'
gem "fog"

# Currency formatting
gem 'autonumeric-rails'

# Breadcrumbs for site navigation
gem 'breadcrumbs_on_rails'

# Pagination
gem 'kaminari'

# Twilio
gem 'twilio-ruby', '~> 4.11.1'

# public pages
gem 'high_voltage', '~> 3.0'

# Exception mailer
gem 'rollbar'

# Dynamic Error Handling
gem 'rambulance', '~> 0.4'

# JSON parsing
gem 'oj', '~> 2.12.14'

# Mailchimp manipulation gem
gem 'gibbon'

# Payment
gem 'stripe'

gem 'activerecord-session_store'

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem "letter_opener"

  # Better error page for Rack apps
  gem "better_errors"
  gem "binding_of_caller"
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'capybara'
  gem 'dotenv-rails'
  gem 'factory_girl_rails'
  gem 'faker'

  # Style verifier
  gem 'rubocop', require: false
end

group :test do
  gem 'guard-rspec', require: false
  gem 'rspec-rails', '~> 3.4'
  gem 'spring-commands-rspec'
  gem 'webmock'
  gem 'stripe-ruby-mock', '~> 2.4.0', :require => 'stripe_mock'
end
