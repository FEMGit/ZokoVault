Rails.application.routes.draw do

  # always declare root path(s) first
  authenticated :user do
    root 'welcome#index', as: :authenticated_root
  end
  root to: 'high_voltage/pages#show', id: 'index'
  get '/index', to: redirect('/')

  resources :final_wishes
  resources :taxes
  resources :relationships
  resources :vendor_accounts
  resources :vendors
  resources :contacts
  devise_for :users, controllers: { registrations: 'registrations', confirmations: 'confirmations', passwords: 'passwords', sessions: 'sessions',
                                    unlocks: 'unlocks' }, :path => 'users', :path_names => { :sign_up => 'sign_up_form' }

  devise_scope :user do
    get 'users/password/corporate_edit/:uuid', to: 'passwords#corporate_edit', as: :corporate_edit_password
  end

  scope 'insurance' do
    resources :lives, controller: :life_and_disabilities
    resources :properties, controller: :property_and_casualties
    resources :healths
  end

  delete 'insurance/properties/provider/:id' => 'property_and_casualties#destroy_provider'
  delete 'insurance/healths/provider/:id' => 'healths#destroy_provider'
  delete 'insurance/lives/provider/:id' => 'life_and_disabilities#destroy_provider'

  # Insurance Update All
  post 'insurance/lives/update_all' => 'life_and_disabilities#update_all'
  post 'insurance/healths/update_all' => 'healths#update_all'
  post 'insurance/properties/update_all' => 'property_and_casualties#update_all'

  # Mailer
  post 'contact_us', to: 'messages#create'
  post 'mailing_list', to: 'interested_users#create'
  post 'users/sign_up_form', as: :sign_up

  # Taxes
  post 'taxes/update_tax_preparers', to: 'taxes#update_tax_preparers', as: :tax_update_preparers
  get 'taxes/:tax', to: 'taxes#show', as: :show_tax
  get 'taxes/new/:year', to: 'taxes#create'

  get 'files' => 'welcome#files'
  get 'cards' => 'welcome#cards'
  get 'cardcolumn' => 'welcome#cardcolumn'
  get 'thank_you' => 'welcome#thank_you'
  get 'email_confirmed' => 'welcome#email_confirmed'
  get 'onboarding_back' => 'welcome#onboarding_back', as: :onboarding_back

  # Default category pages ?Could probably be done better programatically?
  get 'wills_powers_of_attorney' => 'categories#wills_powers_of_attorney'
  get 'trusts_entities' => 'categories#trusts_entities'
  get 'healthcare_choices' => 'categories#healthcare_choices'
  get 'insurance' => 'categories#insurance', as: 'insurance'
  get 'shared' => 'categories#shared'
  get 'shared_view' => 'categories#shared_view_dashboard'
  get 'web_accounts' => 'categories#web_accounts'

  resources :interested_users
  get 'mailing_list_confirm' => 'interested_users#mailing_list_confirm'

  resources :users, only: [:index, :destroy]

  # Wills
  get 'wills/new(/:shared_user_id)', to: 'wills#new', as: :new_will
  get 'wills/edit/:id(/:shared_user_id)', to: 'wills#edit', as: :edit_will
  get 'wills/show/:id(/:shared_user_id)', to: 'wills#show', as: :will
  patch 'wills/show/:id', to: 'wills#update'
  patch 'wills/:id', to: 'wills#update'
  get 'wills', to: 'wills#index', as: :wills
  post 'wills', to: 'wills#create'
  put 'wills', to: 'wills#update'
  delete 'wills/:id', to: 'wills#destroy'

  # Powers of Attorney
  get 'power_of_attorneys/new(/:shared_user_id)', to: 'power_of_attorneys#new', as: :new_power_of_attorney
  get 'power_of_attorneys/edit/:id(/:shared_user_id)', to: 'power_of_attorneys#edit', as: :edit_power_of_attorney
  get 'power_of_attorneys/show/:id(/:shared_user_id)', to: 'power_of_attorneys#show', as: :power_of_attorney
  patch 'power_of_attorneys/show/:id', to: 'power_of_attorneys#update'
  patch 'power_of_attorneys/:id', to: 'power_of_attorneys#update'
  get 'power_of_attorneys', to: 'power_of_attorneys#index', as: :power_of_attorneys
  post 'power_of_attorneys', to: 'power_of_attorneys#create'
  put 'power_of_attorneys', to: 'power_of_attorneys#update'
  delete 'power_of_attorneys/:id', to: 'power_of_attorneys#destroy'
  delete 'power_of_attorneys/powers_of_attorney_contact/:id', to: 'power_of_attorneys#destroy_power_of_attorney_contact', as: :delete_power_of_attorney
  get 'power_of_attorneys/new/get_powers_of_attorney_details', to: 'power_of_attorneys#get_powers_of_attorney_details'

  # Trusts
  get 'trusts/new(/:shared_user_id)', to: 'trusts#new', as: :new_trust
  get 'trusts/edit/:id(/:shared_user_id)', to: 'trusts#edit', as: :edit_trust
  get 'trusts/show/:id(/:shared_user_id)', to: 'trusts#show', as: :trust
  patch 'trusts/show/:id', to: 'trusts#update'
  patch 'trusts/:id', to: 'trusts#update'
  get 'trusts', to: 'trusts#index', as: :trusts
  post 'trusts', to: 'trusts#create'
  post 'trusts/update_all', to: 'trusts#update_all'
  put 'trusts', to: 'trusts#update'
  delete 'trusts/:id', to: 'trusts#destroy'

  # Entities
  get 'entities/new(/:shared_user_id)', to: 'entities#new', as: :new_entity
  get 'entities/:id/edit(/:shared_user_id)', to: 'entities#edit', as: :edit_entity
  patch 'entities/:id', to: 'entities#update'
  get 'entities/:id(/:shared_user_id)', to: 'entities#show', as: :entity
  post 'entities', to: 'entities#create', as: :entities
  post 'entities/update_all', to: 'entities#update_all'
  delete 'entities/:id', to: 'entities#destroy'

  resources :categories do
    member do
      post :share
      get :share_category
      delete 'share_category/:contact_id', to: 'categories#destroy_share_category'
    end
  end

  # contacts
  get 'contacts/relationship_values/:contact_type(/:shared_user_id)', to: 'contacts#relationship_values'
  get 'contacts/new(/:shared_user_id)', to: 'contacts#new', as: :contact_new
  get 'contacts/:id(/:shared_user_id)', to: 'contacts#show', as: :contact_details
  get 'contacts/:id/edit(/:shared_user_id)', to: 'contacts#edit', as: :edit_contact_details


  # insurance details and create new account routes
  get 'insurance/:group/new_account', to: 'categories#new_account', as: :new_account_category
  get 'insurance/:group/details', to: 'categories#details_account', as: :details_account_category

  get 'shares/expired/:shared_user_id' => 'shares#shared_user_expired', as: :shared_expired
  resources :shares
  get 'shares' => 'shares#index'
  get 'shares/new/:document' => 'shares#new'

  resources :documents, param: :uuid
  get 'documents/get_drop_down_options/:category(/:shared_user_id)', to: 'documents#get_drop_down_options'
  get 'documents/get_card_names/:category(/:shared_user_id)', to: 'documents#get_card_names'
  get 'documents/document_category_share_contacts/:category(/:shared_user_id)', to: 'documents#document_category_share_contacts'
  get 'documents/document_subcategory_share_contacts/:category/:subcategory(/:shared_user_id)', to: 'documents#document_subcategory_share_contacts'
  get 'documents/new(/:shared_user_id)', to: 'documents#new', as: :new_documents
  get 'documents/edit/:uuid(/:shared_user_id)', to: 'documents#edit', as: :edit_documents
  get 'documents/download/:uuid(/:shared_user_id)', to: 'documents#download', as: :download_document
  get 'documents/preview/:uuid(/:shared_user_id)', to: 'documents#preview', as: :preview_document
  get 'shared_view/:shared_user_id/documents/:uuid', to: 'documents#show', as: :shared_document
  post 'documents/mass_document_upload(/:shared_user_id)', to: 'documents#mass_document_upload', as: :mass_document_upload

  get 'account_settings', to: 'account_settings#index', as: :account_settings
  get 'account_settings/account_users', to: 'account_settings#account_users', as: :account_users
  get 'account_settings/login_settings', to: 'account_settings#login_settings', as: :login_settings
  get 'account_settings/manage_subscription', to: 'account_settings#manage_subscription', as: :manage_subscription
  get 'account_settings/phone_setup', to: 'account_settings#phone_setup', as: :account_settings_phone_setup
  put 'account_settings/phone_setup_update', to: 'account_settings#phone_setup_update', as: :account_settings_phone_update
  get 'account_settings/billing_info', to: 'account_settings#billing_info', as: :billing_info
  get 'account_settings/cancel_subscription', to: 'account_settings#cancel_subscription', as: :cancel_subscription
  get 'account_settings/invoice_information/:id', to: 'account_settings#invoice_information', as: :invoice_information
  get 'account_settings/update_subscription_information(/:corporate)', to: 'account_settings#update_subscription_information', as: :update_subscription_information
  patch 'account_settings/update', to: 'account_settings#update'
  patch 'account_settings/update_account_users', to: 'account_settings#update_account_users', as: :account_settings_update_account_users
  patch 'account_settings/update_login_settings', to: 'account_settings#update_login_settings'
  patch 'account_settings/cancel_subscription_update', to: 'account_settings#cancel_subscription_update', as: :cancel_subscription_update
  post 'account_settings/send_code', to: 'account_settings#send_code', as: :send_code_account_settings
  post 'account_settings/verify_code', to: 'account_settings#verify_code', as: :verify_code_account_settings
  post 'account_settings/update_payment(/:corporate)', to: 'account_settings#update_payment', as: :update_payment_account_settings
  post 'account_settings/store_corporate_payment', to: 'account_settings#store_corporate_payment', as: :store_corporate_payment

  resources :account_traffics
  get 'account_traffic', to: 'account_traffics#index', as: :user_account_traffics

  resource :user_profile
  get 'my_profile' => 'user_profiles#show'

  get 'account/trial_membership_ended' => 'accounts#trial_membership_ended', as: :trial_ended
  get 'account/trial_membership_update' => 'accounts#trial_membership_update', as: :trial_membership_update
  get 'account/questionnaire' => 'accounts#trial_questionnaire', as: :trial_questionnaire
  put 'account/questionnaire' => 'accounts#trial_questionnaire_update'
  get 'account/first_run' => 'accounts#first_run', as: :first_run
  get 'account/upgrade' => 'accounts#upgrade', as: :account_upgrade
  get 'account/payment' => 'accounts#payment', as: :payment
  get 'account/corporate_user_type' => 'accounts#corporate_user_type', as: :corporate_user_type
  get 'account/corporate_logo' => 'accounts#corporate_logo', as: :corporate_logo
  get 'account/corporate_account_options' => 'accounts#corporate_account_options', as: :corporate_account_options
  get 'account/how_billing_works' => 'accounts#how_billing_works', as: :how_billing_works
  get 'account/billing_types' => 'accounts#billing_types', as: :billing_types
  get 'account/corporate_credit_card' => 'accounts#corporate_credit_card', as: :corporate_credit_card
  post 'account/corporate_user_type_update' => 'accounts#corporate_user_type_update', as: :corporate_user_type_update
  post 'account/corporate_logo_update' => 'accounts#corporate_logo_update', as: :corporate_logo_update
  post 'account/corporate_account_options_update' => 'accounts#corporate_account_options_update', as: :corporate_account_options_update
  put 'account/terms_of_service_update' => 'accounts#terms_of_service_update', as: :account_term_of_service
  put 'account/phone_setup_update' => 'accounts#phone_setup_update', as: :account_phone_setup
  put 'account/login_settings_update' => 'accounts#login_settings_update', as: :account_login_settings
  put 'account/user_type_update' => 'accounts#user_type_update', as: :account_user_type

  resource :account, only: [:update, :show] do
    collection do
      get :terms_of_service
      get :zoku_vault_info
      get :phone_setup
      get :login_settings
      get :user_type
      get :my_profile
      post :send_code
      post :apply_promo_code
      get :subscriptions
      get :yearly_subscription
      put :send_code
      post :mfa_verify_code
      put :mfa_verify_code
    end
  end

  # Tutorials
  get 'tutorials/getting_started/primary_contacts' => 'tutorials#primary_contacts', as: :tutorial_primary_contacts
  get 'tutorials/getting_started/trusted_advisors' => 'tutorials#trusted_advisors', as: :tutorial_trusted_advisors
  get 'tutorials/getting_started/important_documents' => 'tutorials#important_documents', as: :tutorial_important_documents
  get 'tutorials/getting_started/new_document' => 'tutorials#new_document', as: :tutorial_new_document
  get 'tutorials/getting_started/video' => 'tutorials#video', as: :tutorial_video

  get 'tutorials/confirmation', to: 'tutorials#confirmation', as: :tutorials_confirmation
  get 'tutorials/lets_get_started', to: 'tutorials#lets_get_started', as: :tutorials_lets_get_started
  get 'tutorials/vault_co_owners', to: 'tutorials#vault_co_owners', as: :tutorials_vault_co_owners
  get 'tutorials/tutorials_end', to: 'tutorials#tutorials_end', as: :tutorials_end
  resources :tutorials, except: :destroy do
    get '/:page_id', to: 'pages#show', as: :page
    post '/destroy', to: 'tutorials#destroy'
    post '/create_wills', to: 'tutorials#create_wills', as: :create_wills
  end

  resources :vault_entries, only: [:index, :new, :show, :create]

  resource :mfa, only: [:show, :create, :resend_code]
  get 'resend_code', to: 'mfas#resend_code', as: :resend_code

  # Usage metrics path
  get 'usage_metrics/update_site_completed', to: 'usage_metrics#update_information', as: :update_usage_metrics
  resources :usage_metrics
  get 'usage_metrics/error_details/:id', to: 'usage_metrics#error_details', as: :user_error_details
  get 'usage_metrics/statistic_details/:id', to: 'usage_metrics#statistic_details', as: :statistic_details
  get 'usage_errors', to: 'usage_metrics#errors'
  get 'usage_metrics/statistic_details/:id/edit', to: 'usage_metrics#edit_user', as: :admin_edit_user
  get 'usage_metrics/error_details/:id/extend_trial', to: 'usage_metrics#extend_trial', as: :admin_extend_trial
  get 'usage_metrics/error_details/:id/create_trial', to: 'usage_metrics#create_trial', as: :admin_create_trial
  get 'usage_metrics/error_details/:id/cancel_trial', to: 'usage_metrics#cancel_trial', as: :admin_cancel_trial
  post 'usage_metrics/statistic_details/update_user/:id', to: 'usage_metrics#update_user', as: :usage_metrics_update_user

  # Financial information
  get 'financial_information' => 'financial_information#index', as: 'financial_information'
  get 'financial_information/value_negative/:type', to: 'financial_information#value_negative'
  get 'financial_information/balance_sheet', to: 'financial_information#balance_sheet', as: :financial_information_balance_sheet
  post 'financial_information/update_balance_sheet', to: 'financial_information#update_balance_sheet', as: :update_balance_sheet

  # Financial alternative
  get 'financial_information/alternative/new(/:shared_user_id)', to: 'financial_alternative#new', as: :add_alternative
  get 'financial_information/alternative/show/:id(/:shared_user_id)', to: 'financial_alternative#show', as: :show_alternative
  get 'financial_information/alternative/:id/edit(/:shared_user_id)', to: 'financial_alternative#edit', as: :edit_alternative
  get 'financial_information/alternative/:id(/:shared_user_id)', to: 'financial_alternative#show', as: :account_alternative
  post 'financial_information/alternative/add_alternative', to: 'financial_alternative#create', as: :create_alternative
  post 'financial_information/alternative/update_all', to: 'financial_alternative#update_all'
  put 'financial_information/alternative/add_alternative', to: 'financial_alternative#update'
  delete 'financial_information/alternative/provider/:id', to: 'financial_alternative#destroy_provider', as: :delete_provider_alternative
  delete 'financial_information/alternative/:id', to: 'financial_alternative#destroy', as: :delete_alternative

  # Financial Account
  get 'financial_information/account/new(/:shared_user_id)', to: 'financial_account#new', as: :add_account
  get 'financial_information/account/show/:id(/:shared_user_id)', to: 'financial_account#show', as: :show_account
  get 'financial_information/account/:id/edit(/:shared_user_id)', to: 'financial_account#edit', as: :edit_account
  get 'financial_information/account/:id(/:shared_user_id)', to: 'financial_account#show', as: :account_details
  post 'financial_information/account/add_account', to: 'financial_account#create', as: :create_account
  post 'financial_information/account/update_all', to: 'financial_account#update_all'
  put 'financial_information/account/add_account', to: 'financial_account#update'
  delete 'financial_information/account/provider/:id', to: 'financial_account#destroy_provider', as: :delete_provider_account
  delete 'financial_information/account/:id', to: 'financial_account#destroy', as: :delete_account

  # Financial Property
  get 'financial_information/property/new(/:shared_user_id)', to: 'financial_property#new', as: :add_property
  get 'financial_information/property/show/:id(/:shared_user_id)', to: 'financial_property#show', as: :show_property
  get 'financial_information/property/:id/edit(/:shared_user_id)', to: 'financial_property#edit', as: :edit_financial_property
  get 'financial_information/property/:id(/:shared_user_id)', to: 'financial_property#show', as: :property_details
  post 'financial_information/property/add_property', to: 'financial_property#create', as: :create_property
  post 'financial_information/property/update_all', to: 'financial_property#update_all', as: :update_all
  delete 'financial_information/property/:id', to: 'financial_property#destroy', as: :delete_property

  # Financial Investment
  get 'financial_information/investment/new(/:shared_user_id)', to: 'financial_investment#new', as: :add_investment
  get 'financial_information/investment/show/:id(/:shared_user_id)', to: 'financial_investment#show', as: :show_investment
  get 'financial_information/investment/:id/edit(/:shared_user_id)', to: 'financial_investment#edit', as: :edit_investment
  get 'financial_information/investment/:id(/:shared_user_id)', to: 'financial_investment#show', as: :investment_details
  post 'financial_information/investment/add_investment', to: 'financial_investment#create', as: :create_investment
  post 'financial_information/investment/update_all', to: 'financial_investment#update_all'
  put 'financial_information/investment/add_investment', to: 'financial_investment#update'
  delete 'financial_information/investment/:id', to: 'financial_investment#destroy', as: :delete_investment

  resources :financial_account
  resources :financial_property
  resources :financial_investment
  resources :financial_alternative

  # Shared view
  get 'shared_view/:shared_user_id/dashboard' => 'shared_view#dashboard', as: :shared_view_dashboard
  get 'shared_view/:shared_user_id/wills_powers_of_attorney' => 'shared_view#wills_powers_of_attorney', as: :shared_view_wills_powers_of_attorney
  get 'shared_view/:shared_user_id/trusts_entities' => 'shared_view#trusts_entities', as: :shared_view_trusts_entities
  get 'shared_view/:shared_user_id/insurance' => 'shared_view#insurance', as: :shared_view_insurance
  get 'shared_view/:shared_user_id/taxes' => 'shared_view#taxes', as: :shared_view_taxes
  get 'shared_view/:shared_user_id/final_wishes' => 'shared_view#final_wishes', as: :shared_view_final_wishes
  get 'shared_view/:shared_user_id/financial_information' => 'shared_view#financial_information', as: :shared_view_financial_information
  get 'shared_view/:shared_user_id/documents' => 'shared_view#documents', as: :shared_view_documents
  get 'shared_view/:shared_user_id/contacts' => 'shared_view#contacts', as: :shared_view_contacts

  get 'shared_view/:shared_user_id/wills' => 'shared_view#wills', as: :shared_view_wills
  get 'shared_view/:shared_user_id/trusts' => 'shared_view#trusts', as: :shared_view_trusts
  get 'shared_view/:shared_user_id/power_of_attorneys' => 'shared_view#power_of_attorneys', as: :shared_view_power_of_attorneys

  # Documents
  get 'shared_view/:shared_user_id/documents/:uuid' => 'documents#show', as: :shared_documents

  # Search
  get "/search", to: "search#index", as: :search

  # Shared insurance healths
  get 'shared_view/:shared_user_id/insurance/health' => 'healths#index', as: :shared_healths
  get 'shared_view/:shared_user_id/insurance/health/:id' => 'healths#show', as: :shared_health
  get 'shared_view/:shared_user_id/insurance/healths/new' => 'healths#new', as: :shared_new_health
  get 'shared_view/:shared_user_id/insurance/health/:id/edit' => 'healths#edit', as: :shared_edit_health

  # Shared insurance properties
  get 'shared_view/:shared_user_id/insurance/property' => 'property_and_casualties#index', as: :shared_properties
  get 'shared_view/:shared_user_id/insurance/property/:id' => 'property_and_casualties#show', as: :shared_property
  get 'shared_view/:shared_user_id/insurance/properties/new' => 'property_and_casualties#new', as: :shared_new_property
  get 'shared_view/:shared_user_id/insurance/property/:id/edit' => 'property_and_casualties#edit', as: :shared_edit_property

  # Shared insurance lives
  get 'shared_view/:shared_user_id/insurance/life' => 'life_and_disabilities#index', as: :shared_lives
  get 'shared_view/:shared_user_id/insurance/life/:id' => 'life_and_disabilities#show', as: :shared_life
  get 'shared_view/:shared_user_id/insurance/lives/new' => 'life_and_disabilities#new', as: :shared_new_life
  get 'shared_view/:shared_user_id/insurance/life/:id/edit' => 'life_and_disabilities#edit', as: :shared_edit_life

  # Shared taxes
  get 'shared_view/:shared_user_id/taxes/:id' => 'taxes#show', as: :shared_taxes
  get 'shared_view/:shared_user_id/taxes/:id/edit' => 'taxes#edit', as: :shared_taxes_edit
  get 'shared_view/:shared_user_id/taxes/new/:year' => 'taxes#new', as: :shared_new_taxes

  # Shared final wishes
  get 'shared_view/:shared_user_id/final_wishes/:id' => 'final_wishes#show', as: :shared_final_wishes
  get 'shared_view/:shared_user_id/final_wishes/:id/edit' => 'final_wishes#edit', as: :shared_final_wishes_edit
  get 'shared_view/:shared_user_id/final_wishes/new/:group' => 'final_wishes#new', as: :shared_new_final_wishes

  # Stripe callbacks
  scope :stripe do
    # Key must match token on Stripe dashboard to authenticate callback
    post "/subscription_created" => "stripe_callbacks#subscription_created"
    post "/payment_success" => "stripe_callbacks#payment_success"
    post "/payment_failure" => "stripe_callbacks#payment_failure"
    post "/subscription_expired" => "stripe_callbacks#subscription_expired"
  end

  # Information pages
  get "/about", to: "pages#about", as: :about
  get "/careers", to: "pages#careers", as: :careers
  get "/contact_us", to: "pages#contact_us", as: :contact_page
  get "/corporate_details", to: "pages#corporate_details", as: :corporate_details
  get "/mailing_list", to: "pages#mailing_list", as: :mailing_list_page
  get "/pricing", to: "pages#pricing", as: :pricing
  get "/privacy_policy", to: "pages#privacy_policy", as: :privacy_policy
  get "/resources", to: "pages#resources", as: :resources
  get "/security", to: "pages#security", as: :security
  get "/setup", to: "pages#setup", as: :setup
  get "/styleguide", to: "pages#styleguide"
  get "/terms_of_service", to: "pages#terms_of_service", as: :terms_of_service
  get "/product_video", to: "pages#product_video"
  get "/html_template", to: "pages#html_template", as: :html_template

  get '/support/new_message', to: 'email_support#index', as: :email_support
  post '/support/new_message', to: 'email_support#send_email'

  # Email helper
  get '/email/share_invitation_mailer_name/:contact_id', to: 'email#share_invitation_mailer_name'
  get 'email/email_preview_line/:contact_id', to: 'email#email_preview_line'

  # Corporate Account
  get '/corporate', to: 'corporate_accounts#index', as: :corporate_accounts
  get '/corporate/account_settings', to: 'corporate_accounts#account_settings', as: :corporate_account_settings
  get '/corporate/edit_account_settings', to: 'corporate_accounts#edit_account_settings', as: :edit_corporate_settings
  get '/corporate/billing_information', to: 'corporate_accounts#billing_information', as: :corporate_billing_information
  post '/corporate/update_account_settings/:id', to: 'corporate_accounts#update_account_settings', as: :update_corporate_settings
  post '/corporate/send_invitation/:contact_id(/:account_type)', to: 'corporate_accounts#send_invitation', as: :corporate_send_invitation
  post '/corporate', to: 'corporate_accounts#create', as: :create_corporate_account
  put '/corporate', to: 'corporate_accounts#update', as: :update_corporate_account
  resources :corporate_accounts
  
  # Corporate Employee Accounts
  post '/corporate_employee', to: 'corporate_employees#create', as: :create_corporate_employee
  post '/corporate_employee/remove_employee/:contact_id', to: 'corporate_employees#remove_employee', as: :corporate_employee_remove
  put '/corporate_employee', to: 'corporate_employees#update', as: :update_corporate_employee
  resources :corporate_employees
end
