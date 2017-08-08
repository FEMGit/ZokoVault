Rails.application.routes.draw do

  # always declare root path(s) first
  authenticated :user do
    root 'welcome#index', as: :authenticated_root
  end
  root to: 'high_voltage/pages#show', id: 'index'
  get '/index', to: redirect('/')

  resources :relationships
  resources :vendor_accounts
  resources :vendors
  devise_for :users, controllers: { registrations: 'registrations', confirmations: 'confirmations', passwords: 'passwords', sessions: 'sessions',
                                    unlocks: 'unlocks' }, :path => 'users', :path_names => { :sign_up => 'sign_up_form' }

  devise_scope :user do
    get 'users/password/create_new_invitation/:uuid', to: 'passwords#create_new_invitation', as: :create_new_password_invitation
    match 'active' => 'sessions#active', via: :get
    match 'timeout' => 'sessions#timeout', via: :get
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
  resources :taxes
  post 'taxes/update_tax_preparers', to: 'taxes#update_tax_preparers', as: :tax_update_preparers
  
  # Final Wishes
  resources :final_wishes

  get 'files' => 'welcome#files'
  get 'cards' => 'welcome#cards'
  get 'cardcolumn' => 'welcome#cardcolumn'
  get 'thank_you' => 'welcome#thank_you'
  get 'email_confirmed' => 'welcome#email_confirmed'
  get 'password_link_expired(/:corporate)' => 'welcome#reset_password_expired', as: :password_link_expired
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
  
  # Online Accounts
  get 'online_accounts/reveal_password/:account_id(/:shared_user_id)', to: 'online_accounts#reveal_password'
  get 'online_accounts', to: 'online_accounts#index', as: :online_accounts
  get 'online_accounts/new(/:shared_user_id)', to: 'online_accounts#new', as: :new_online_account
  get 'online_accounts/:id/edit(/:shared_user_id)', to: 'online_accounts#edit', as: :edit_online_account
  patch 'online_accounts/:id', to: 'online_accounts#update', as: :online_account
  post 'online_accounts', to: 'online_accounts#create'
  post 'online_accounts/update_all', to: 'online_accounts#update_all'
  delete 'online_accounts/:id', to: 'online_accounts#destroy'

  # Contacts
  get 'contacts/relationship_values/:contact_type(/:shared_user_id)', to: 'contacts#relationship_values'
  get 'contacts/new(/:shared_user_id)', to: 'contacts#new', as: :new_contact
  get 'contacts/:id(/:shared_user_id)', to: 'contacts#show', as: :contact
  get 'contacts/:id/edit(/:shared_user_id)', to: 'contacts#edit', as: :edit_contact
  resources :contacts, except: [:new, :edit, :show]

  # insurance details and create new account routes
  get 'insurance/:group/new_account', to: 'categories#new_account', as: :new_account_category
  get 'insurance/:group/details', to: 'categories#details_account', as: :details_account_category

  # Shares
  get 'shares' => 'shares#index'
  get 'shares/expired/:shared_user_id' => 'shares#shared_user_expired', as: :shared_user_expired

  # Documents
  get 'documents/get_drop_down_options/:category(/:shared_user_id)', to: 'documents#get_drop_down_options'
  get 'documents/get_card_names/:category(/:shared_user_id)', to: 'documents#get_card_names'
  get 'documents/document_category_share_contacts/:category(/:shared_user_id)', to: 'documents#document_category_share_contacts'
  get 'documents/document_subcategory_share_contacts/:category/:subcategory(/:shared_user_id)', to: 'documents#document_subcategory_share_contacts'
  get 'documents/', to: 'documents#index', as: :documents
  post 'documents/', to: 'documents#create'
  get 'documents/new(/:shared_user_id)', to: 'documents#new', as: :new_document
  get 'documents/edit/:uuid(/:shared_user_id)', to: 'documents#edit', as: :edit_document
  get 'documents/:uuid', to: 'documents#show', as: :document
  patch 'documents/:uuid', to: 'documents#update'
  delete 'documents/:uuid', to: 'documents#destroy'
  get 'documents/download/:uuid(/:shared_user_id)', to: 'documents#download', as: :download_document
  get 'documents/preview/:uuid(/:shared_user_id)', to: 'documents#preview', as: :preview_document
  get 'shared_view/:shared_user_id/documents/:uuid', to: 'documents#show', as: :shared_view_document
  post 'documents/mass_document_upload(/:shared_user_id)', to: 'documents#mass_document_upload', as: :mass_document_upload
  resources :documents, except: [:new, :edit], param: :uuid

  # Account Settings
  get 'account_settings', to: 'account_settings#index', as: :account_settings
  get 'account_settings/remove_corporate_access/:contact_id', to: 'account_settings#remove_corporate_access', as: :remove_corporate_access_account_settings
  get 'account_settings/remove_corporate_payment', to: 'account_settings#remove_corporate_payment', as: :remove_corporate_payment_account_settings
  get 'account_settings/vault_co_owners', to: 'account_settings#vault_co_owners', as: :vault_co_owners_account_settings
  get 'account_settings/login_settings', to: 'account_settings#login_settings', as: :login_settings_account_settings
  get 'account_settings/manage_subscription', to: 'account_settings#manage_subscription', as: :manage_subscription_account_settings
  get 'account_settings/vault_inheritance', to: 'account_settings#vault_inheritance', as: :vault_inheritance_account_settings
  get 'account_settings/phone_setup', to: 'account_settings#phone_setup', as: :phone_setup_account_settings
  put 'account_settings/phone_setup_update', to: 'account_settings#phone_setup_update', as: :phone_update_account_settings
  get 'account_settings/billing_info', to: 'account_settings#billing_info', as: :billing_info_account_settings
  get 'account_settings/cancel_subscription', to: 'account_settings#cancel_subscription', as: :cancel_subscription_account_settings
  get 'account_settings/invoice_information/:id', to: 'account_settings#invoice_information', as: :invoice_information_account_settings
  get 'account_settings/update_subscription_information(/:corporate)', to: 'account_settings#update_subscription_information', as: :update_subscription_information_account_settings
  get 'account_settings/thank_you_for_subscription/:plan_id(/:corporate_client_id)', to: 'account_settings#thank_you_for_subscription', as: :thank_you_for_subscription_account_settings
  patch 'account_settings/update', to: 'account_settings#update'
  patch 'account_settings/update_vault_co_owner', to: 'account_settings#update_vault_co_owner', as: :update_vault_co_owner_account_settings
  patch 'account_settings/update_vault_inheritance', to: 'account_settings#update_vault_inheritance', as: :update_vault_inheritance_account_settings
  patch 'account_settings/update_login_settings', to: 'account_settings#update_login_settings'
  patch 'account_settings/cancel_subscription_update', to: 'account_settings#cancel_subscription_update', as: :cancel_subscription_update_account_settings
  patch 'account_settings/remove_corporate_access_update/:contact_id', to: 'account_settings#remove_corporate_access_update', as: :remove_corporate_access_update_account_settings
  patch 'account_settings/remove_corporate_payment_update', to: 'account_settings#remove_corporate_payment_update', as: :remove_corporate_payment_update_account_settings
  post 'account_settings/send_code', to: 'account_settings#send_code', as: :send_code_account_settings
  post 'account_settings/verify_code', to: 'account_settings#verify_code', as: :verify_code_account_settings
  post 'account_settings/update_payment(/:corporate)', to: 'account_settings#update_payment', as: :update_payment_account_settings
  post 'account_settings/store_corporate_payment', to: 'account_settings#store_corporate_payment', as: :store_corporate_payment_account_settings

  # Account Traffic
  get 'account_traffic', to: 'account_traffics#index', as: :account_traffics

  # User Profile
  resources :user_profiles, only: [:update]
  get 'my_profile' => 'user_profiles#index', as: :user_profiles
  get 'my_profile/edit' => 'user_profiles#edit', as: :edit_user_profile

  # Account
  get 'account/trial_membership_ended' => 'accounts#trial_membership_ended', as: :trial_membership_ended_accounts_path
  get 'account/trial_membership_update' => 'accounts#trial_membership_update', as: :trial_membership_update_accounts
  get 'account/questionnaire' => 'accounts#trial_questionnaire', as: :trial_questionnaire_accounts
  put 'account/questionnaire' => 'accounts#trial_questionnaire_update'
  get 'account/first_run' => 'accounts#first_run', as: :first_run_accounts
  get 'account/upgrade' => 'accounts#upgrade', as: :upgrade_accounts
  get 'account/payment' => 'accounts#payment', as: :payment_accounts
  get 'account/corporate_user_type' => 'accounts#corporate_user_type', as: :corporate_user_type_accounts
  get 'account/corporate_logo' => 'accounts#corporate_logo', as: :corporate_logo_accounts
  get 'account/corporate_account_options' => 'accounts#corporate_account_options', as: :corporate_account_options_accounts
  get 'account/how_billing_works' => 'accounts#how_billing_works', as: :how_billing_works_accounts
  get 'account/billing_types' => 'accounts#billing_types', as: :billing_types_accounts
  get 'account/corporate_credit_card' => 'accounts#corporate_credit_card', as: :corporate_credit_card_accounts
  post 'account/corporate_user_type_update' => 'accounts#corporate_user_type_update', as: :corporate_user_type_update_accounts
  post 'account/corporate_logo_update' => 'accounts#corporate_logo_update', as: :corporate_logo_update_accounts
  post 'account/corporate_account_options_update' => 'accounts#corporate_account_options_update', as: :corporate_account_options_update_accounts
  put 'account/terms_of_service_update' => 'accounts#terms_of_service_update', as: :terms_of_service_update_accounts
  put 'account/phone_setup_update' => 'accounts#phone_setup_update', as: :phone_setup_update_accounts
  put 'account/login_settings_update' => 'accounts#login_settings_update', as: :login_settings_update_accounts
  put 'account/user_type_update' => 'accounts#user_type_update', as: :user_type_update_accounts

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
  get 'tutorials/confirmation', to: 'tutorials#confirmation', as: :confirmation_tutorials
  get 'tutorials/lets_get_started', to: 'tutorials#lets_get_started', as: :lets_get_started_tutorials
  get 'tutorials/vault_co_owners', to: 'tutorials#vault_co_owners', as: :vault_co_owners_tutorials
  get 'tutorials/tutorials_end', to: 'tutorials#tutorials_end', as: :tutorials_end_tutorials
  resources :tutorials, except: :destroy do
    get '/:page_id', to: 'tutorials#show', as: :page
    post '/destroy', to: 'tutorials#destroy'
    post '/create_wills', to: 'tutorials#create_wills', as: :create_wills
  end

  resources :vault_entries, only: [:index, :new, :show, :create]

  resource :mfa, only: [:show, :create, :resend_code]
  get 'resend_code', to: 'mfas#resend_code', as: :resend_code_mfas

  # Usage metrics path
  resources :usage_metrics, only: [:index]
  get 'usage_metrics/update_site_completed', to: 'usage_metrics#update_information', as: :update_information_usage_metrics
  get 'usage_metrics/error_details/:id', to: 'usage_metrics#error_details', as: :error_details_usage_metrics
  get 'usage_metrics/statistic_details/:id', to: 'usage_metrics#statistic_details', as: :statistic_details_usage_metrics
  get 'usage_metrics/new_user', to: 'usage_metrics#new_user', as: :new_user_usage_metrics
  get 'usage_errors', to: 'usage_metrics#errors'
  get 'usage_metrics/statistic_details/:id/edit', to: 'usage_metrics#edit_user', as: :edit_user_usage_metrics
  get 'usage_metrics/error_details/:id/extend_trial', to: 'usage_metrics#extend_trial', as: :extend_trial_usage_metrics
  get 'usage_metrics/error_details/:id/create_trial', to: 'usage_metrics#create_trial', as: :create_trial_usage_metrics
  get 'usage_metrics/error_details/:id/cancel_trial', to: 'usage_metrics#cancel_trial', as: :cancel_trial_usage_metrics
  post 'usage_metrics/statistic_details/update_user/:id', to: 'usage_metrics#update_user', as: :update_user_usage_metrics
  post 'usage_metrics/create_user', to: 'usage_metrics#create_user', as: :create_user_usage_metrics
  post 'usage_metrics/send_invitation_email/:user_id', to: 'usage_metrics#send_invitation_email', as: :send_invitation_email_usage_metrics

  # Financial information
  get 'financial_information' => 'financial_information#index', as: 'financial_information'
  get 'financial_information/value_negative/:type', to: 'financial_information#value_negative'
  get 'financial_information/balance_sheet', to: 'financial_information#balance_sheet', as: :balance_sheet_financial_information
  post 'financial_information/update_balance_sheet', to: 'financial_information#update_balance_sheet', as: :update_balance_sheet_financial_information

  # Financial alternative
  get 'financial_information/alternative/new(/:shared_user_id)', to: 'financial_alternative#new', as: :new_financial_alternative
  get 'financial_information/alternative/:id/edit(/:shared_user_id)', to: 'financial_alternative#edit', as: :edit_financial_alternative
  get 'financial_information/alternative/:id(/:shared_user_id)', to: 'financial_alternative#show', as: :financial_alternative
  delete 'financial_information/alternative/:id', to: 'financial_alternative#destroy'
  patch 'financial_information/alternative/update/:id', to: 'financial_alternative#update'
  post 'financial_information/alternative/create', to: 'financial_alternative#create', as: :financial_alternatives
  post 'financial_information/alternative/update_all', to: 'financial_alternative#update_all'
  delete 'financial_information/alternative/provider/:id', to: 'financial_alternative#destroy_provider', as: :financial_alternative_provider

  # Financial Account
  get 'financial_information/account/new(/:shared_user_id)', to: 'financial_account#new', as: :new_financial_account
  get 'financial_information/account/:id/edit(/:shared_user_id)', to: 'financial_account#edit', as: :edit_financial_account
  get 'financial_information/account/:id(/:shared_user_id)', to: 'financial_account#show', as: :financial_account
  delete 'financial_information/account/:id', to: 'financial_account#destroy'
  patch 'financial_information/account/update/:id', to: 'financial_account#update'
  post 'financial_information/account/add_account', to: 'financial_account#create', as: :financial_accounts
  post 'financial_information/account/update_all', to: 'financial_account#update_all'
  delete 'financial_information/account/provider/:id', to: 'financial_account#destroy_provider', as: :financial_account_provider

  # Financial Property
  get 'financial_information/property/new(/:shared_user_id)', to: 'financial_property#new', as: :new_financial_property
  get 'financial_information/property/:id/edit(/:shared_user_id)', to: 'financial_property#edit', as: :edit_financial_property
  get 'financial_information/property/:id(/:shared_user_id)', to: 'financial_property#show', as: :financial_property
  delete 'financial_information/property/:id', to: 'financial_property#destroy'
  patch 'financial_information/property/update/:id', to: 'financial_property#update'
  post 'financial_information/property/add_property', to: 'financial_property#create', as: :financial_properties
  post 'financial_information/property/update_all', to: 'financial_property#update_all'

  # Financial Investment
  get 'financial_information/investment/new(/:shared_user_id)', to: 'financial_investment#new', as: :new_financial_investment
  get 'financial_information/investment/:id/edit(/:shared_user_id)', to: 'financial_investment#edit', as: :edit_financial_investment
  get 'financial_information/investment/:id(/:shared_user_id)', to: 'financial_investment#show', as: :financial_investment
  delete 'financial_information/investment/:id', to: 'financial_investment#destroy'
  patch 'financial_information/investment/update/:id', to: 'financial_investment#update'
  post 'financial_information/investment/add_investment', to: 'financial_investment#create', as: :financial_invstments
  post 'financial_information/investment/update_all', to: 'financial_investment#update_all'
  
  # Shared view
  get 'shared_view/:shared_user_id/contacts' => 'shared_view#contacts', as: :contacts_shared_view
  get 'shared_view/:shared_user_id/dashboard' => 'shared_view#dashboard', as: :dashboard_shared_view
  get 'shared_view/:shared_user_id/documents' => 'shared_view#documents', as: :documents_shared_view
  get 'shared_view/:shared_user_id/final_wishes' => 'shared_view#final_wishes', as: :final_wishes_shared_view
  get 'shared_view/:shared_user_id/financial_information' => 'shared_view#financial_information', as: :financial_information_shared_view
  get 'shared_view/:shared_user_id/insurance' => 'shared_view#insurance', as: :insurance_shared_view
  get 'shared_view/:shared_user_id/online_accounts' => 'shared_view#online_accounts', as: :online_accounts_shared_view
  get 'shared_view/:shared_user_id/taxes' => 'shared_view#taxes', as: :taxes_shared_view
  get 'shared_view/:shared_user_id/trusts_entities' => 'shared_view#trusts_entities', as: :trusts_entities_shared_view
  get 'shared_view/:shared_user_id/wills_powers_of_attorney' => 'shared_view#wills_powers_of_attorney', as: :wills_powers_of_attorney_shared_view
  
  # Search
  get "/search", to: "search#index", as: :search

  # Shared insurance healths
  get 'shared_view/:shared_user_id/insurance/health' => 'healths#index', as: :healths_shared_view
  get 'shared_view/:shared_user_id/insurance/health/:id' => 'healths#show', as: :health_shared_view
  get 'shared_view/:shared_user_id/insurance/healths/new' => 'healths#new', as: :new_health_shared_view
  get 'shared_view/:shared_user_id/insurance/health/:id/edit' => 'healths#edit', as: :edit_health_shared_view

  # Shared insurance properties
  get 'shared_view/:shared_user_id/insurance/property' => 'property_and_casualties#index', as: :property_and_casualties_shared_view
  get 'shared_view/:shared_user_id/insurance/property/:id' => 'property_and_casualties#show', as: :property_and_casualty_shared_view
  get 'shared_view/:shared_user_id/insurance/properties/new' => 'property_and_casualties#new', as: :new_property_and_casualty_shared_view
  get 'shared_view/:shared_user_id/insurance/property/:id/edit' => 'property_and_casualties#edit', as: :edit_property_and_casualty_shared_view

  # Shared insurance lives
  get 'shared_view/:shared_user_id/insurance/life' => 'life_and_disabilities#index', as: :life_and_disabilities_shared_view
  get 'shared_view/:shared_user_id/insurance/life/:id' => 'life_and_disabilities#show', as: :life_and_disability_shared_view
  get 'shared_view/:shared_user_id/insurance/lives/new' => 'life_and_disabilities#new', as: :new_life_and_disability_shared_view
  get 'shared_view/:shared_user_id/insurance/life/:id/edit' => 'life_and_disabilities#edit', as: :edit_life_and_disability_shared_view

  # Shared taxes
  get 'shared_view/:shared_user_id/taxes/:id' => 'taxes#show', as: :tax_shared_view
  get 'shared_view/:shared_user_id/taxes/new/:year' => 'taxes#new', as: :new_tax_shared_view
  get 'shared_view/:shared_user_id/taxes/:id/edit' => 'taxes#edit', as: :edit_tax_shared_view

  # Shared final wishes
  get 'shared_view/:shared_user_id/final_wishes/:id' => 'final_wishes#show', as: :final_wish_shared_view
  get 'shared_view/:shared_user_id/final_wishes/new/:group' => 'final_wishes#new', as: :new_final_wish_shared_view
  get 'shared_view/:shared_user_id/final_wishes/:id/edit' => 'final_wishes#edit', as: :edit_final_wish_shared_view

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
  get '/email/email_preview_line/:contact_id(/:submit_button_text)(/:shared_user_id)', to: 'email#email_preview_line'

  # Corporate Account
  get '/corporate/expired/:shared_user_id', to: 'corporate_accounts#shared_user_expired', as: :shared_user_expired_corporate_accounts
  get '/corporate/account_settings', to: 'corporate_accounts#account_settings', as: :account_settings_corporate_accounts
  get '/corporate/edit_account_settings', to: 'corporate_accounts#edit_account_settings', as: :edit_corporate_settings_corporate_accounts
  get '/corporate/billing_information', to: 'corporate_accounts#billing_information', as: :billing_information_corporate_accounts
  post '/corporate/remove_client/:contact_id', to: 'corporate_accounts#remove_corporate_client', as: :remove_corporate_client_corporate_accounts
  post '/corporate/update_account_settings/:id', to: 'corporate_accounts#update_account_settings', as: :update_account_settings_corporate_accounts
  post '/corporate/send_invitation/:contact_id(/:account_type)', to: 'corporate_accounts#send_invitation', as: :send_invitation_corporate_accounts
  resources :corporate_accounts, path: 'corporate'
  
  # Corporate Employee Accounts
  resources :corporate_employees, except: [:destroy]
  post '/corporate_employee/remove/:contact_id', to: 'corporate_employees#remove', as: :remove_corporate_employee
end
