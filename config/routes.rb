Rails.application.routes.draw do
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

  get 'files' => 'welcome#files'
  get 'filestacktest' => 'welcome#filestacktest'
  get 'styleguide' => 'welcome#styleguide'
  get 'cards' => 'welcome#cards'
  get 'cardcolumn' => 'welcome#cardcolumn'
  get 'thank_you' => 'welcome#thank_you'
  get 'email_confirmed' => 'welcome#email_confirmed'

  # Default category pages ?Could probably be done better programatically?
  get 'my_profile' => 'categories#my_profile'
  get 'estate_planning' => 'categories#estate_planning'
  get 'final_wishes' => 'categories#final_wishes'
  get 'financial_information' => 'categories#financial_information'
  get 'healthcare_choices' => 'categories#healthcare_choices'
  get 'insurance' => 'categories#insurance', as: 'insurance'
  get 'shared' => 'categories#shared'
  get 'shared_view' => 'categories#shared_view_dashboard'
  get 'taxes' => 'categories#taxes'
  get 'web_accounts' => 'categories#web_accounts'
  
  get 'shares/new/:document' => 'shares#new'

  resources :users, only: [:index, :destroy]

  resources :wills
  get 'wills/details/:will', to: 'wills#details', as: :details_will

  resources :trusts
  get 'trusts/details/:trust', to: 'trusts#details', as: :details_trust

  resources :power_of_attorneys
  get 'power_of_attorneys/details/:power_of_attorney', to: 'power_of_attorneys#details', as: :details_attorney, :defaults => {:attorney => 1}

  resources :categories

  # insurance details and create new account routes
  get 'insurance/:group/new_account', to: 'categories#new_account', as: :new_account_category
  get 'insurance/:group/details', to: 'categories#details_account', as: :details_account_category

  resources :shares
  get '/folders/new/(:parent_id)', to: 'folders#new', as: :new_folder

  resources :documents
  get 'documents/get_drop_down_options/:category', to: 'documents#get_drop_down_options'

  resource :account, only: [:update, :show] do
    collection do
      get :setup
      post :send_code
      put :send_code
      post :verify_code
      put :verify_code
    end
  end

  resources :vault_entries, only: [:index, :new, :show, :create]

  resource :mfa, only: [:show, :create]

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
