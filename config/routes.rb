Rails.application.routes.draw do
  resources :final_wishes
  resources :taxes
  resources :relationships
  resources :vendor_accounts
  resources :vendors
  resources :contacts
  devise_for :users, controllers: { registrations: 'registrations', confirmations: 'confirmations' }

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  authenticated :user do
    root 'welcome#index', as: :authenticated_root
  end
  
  #root "index"
  #root "public#index"

  #public
  # get "/:page" => "public#show"
  #
  scope 'insurance' do
    resources :lives, controller: :life_and_disabilities
    resources :properties, controller: :property_and_casualties
    resources :healths
  end

  delete 'insurance/properties/provider/:id' => 'property_and_casualties#destroy_provider'
  delete 'insurance/healths/provider/:id' => 'healths#destroy_provider'
  delete 'insurance/lives/provider/:id' => 'life_and_disabilities#destroy_provider'
  
  # Mailer
  post 'contact-us', to: 'messages#create'
  post 'mailing-list', to: 'interested_users#create'

  # Mailer
  post 'contact-us', to: 'messages#create'
  post 'mailing-list', to: 'interested_users#create'
  
  # Taxes
  get 'taxes/:id/:year', to: 'taxes#show'
  get 'taxes/new/:year', to: 'taxes#create'

  get 'files' => 'welcome#files'
  get 'filestacktest' => 'welcome#filestacktest'
  get 'cards' => 'welcome#cards'
  get 'cardcolumn' => 'welcome#cardcolumn'
  get 'thank_you' => 'welcome#thank_you'
  get 'email_confirmed' => 'welcome#email_confirmed'

  # Default category pages ?Could probably be done better programatically?
  get 'estate_planning' => 'categories#estate_planning'
  get 'financial_information' => 'categories#financial_information'
  get 'healthcare_choices' => 'categories#healthcare_choices'
  get 'insurance' => 'categories#insurance', as: 'insurance'
  get 'shared' => 'categories#shared'
  get 'shared_view' => 'categories#shared_view_dashboard'
  get 'web_accounts' => 'categories#web_accounts'

  get 'shares/new/:document' => 'shares#new'

  resources :interested_users
  get 'mailing_list_confirm' => 'interested_users#mailing_list_confirm'

  resources :users, only: [:index, :destroy]

  resources :wills
  get 'wills/:will', to: 'wills#show', as: :details_will
  get 'wills/new/get_wills_details', to: 'wills#get_wills_details'

  resources :trusts
  get 'trusts/:trust', to: 'trusts#show', as: :details_trust
  get 'trusts/new/get_trusts_details', to: 'trusts#get_trusts_details'
  get 'trusts/create_empty_form/:category', to: 'trusts#create_empty_form'

  resources :power_of_attorneys
  get 'power_of_attorneys/:power_of_attorney', to: 'power_of_attorneys#show', as: :details_attorney
  get 'power_of_attorneys/new/get_powers_of_attorney_details', to: 'power_of_attorneys#get_powers_of_attorney_details'

  resources :categories

  # insurance details and create new account routes
  get 'insurance/:group/new_account', to: 'categories#new_account', as: :new_account_category
  get 'insurance/:group/details', to: 'categories#details_account', as: :details_account_category

  resources :shares
  get '/folders/new/(:parent_id)', to: 'folders#new', as: :new_folder

  resources :documents
  get 'documents/get_drop_down_options/:category', to: 'documents#get_drop_down_options'

  resource :user_profile
  get 'my_profile' => 'user_profiles#show'
  resource :account, only: [:update, :show] do
    collection do
      get :setup
      get :my_profile
      post :send_code
      put :send_code
      post :verify_code
      put :verify_code
    end
  end

  resources :vault_entries, only: [:index, :new, :show, :create]

  resource :mfa, only: [:show, :create, :resend_code]
  get 'resend_code', to: 'mfas#resend_code', as: :resend_code

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
