source 'https://rubygems.org'
ruby "2.3.1"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.6'
# Use sqlite3 as the database for Active Record
gem 'pg'
# Authentication
gem 'devise'

gem 'acts_as_tree'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
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

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'faker'

# Style verifier
gem 'rubocop', require: false
# Guard, watch for file changes, run respective specs
gem 'guard-rspec', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # Rspec
  gem 'rspec-rails', '~> 3.4'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'spring-commands-rspec'
  gem 'dotenv-rails'
end
# Twilio
gem 'twilio-ruby', '~> 4.11.1'

# public pages
gem 'high_voltage', '~> 3.0'

group :test do
  gem 'webmock'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem "letter_opener"
end
