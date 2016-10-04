Rails.application.routes.draw do
  get 'attorneys/new'
  get 'trusts/new'

  resources :relationships
  resources :vendor_accounts
  resources :vendors
  resources :contacts
  devise_for :users, controllers: { registrations: 'registrations' }

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root to: 'welcome#index'
  get 'files' => 'welcome#files'
  get 'filestacktest' => 'welcome#filestacktest'
  get 'styleguide' => 'welcome#styleguide'
  get 'cards' => 'welcome#cards'
  get 'thank_you' => 'welcome#thank_you'

  # Default category pages ?Could probably be done better programatically?
  get 'my_profile' => 'categories#my_profile'
  get 'estate_planning' => 'categories#estate_planning'
  get 'final_wishes' => 'categories#final_wishes'
  get 'financial_information' => 'categories#financial_information'
  get 'healthcare_choices' => 'categories#healthcare_choices'
  get 'insurance' => 'categories#insurance', as: 'insurance'
  get 'shared' => 'categories#shared'
  get 'taxes' => 'categories#taxes'
  get 'web_accounts' => 'categories#web_accounts'

  get 'shares/new/:document' => 'shares#new'

  resources :users, only: [:index, :destroy]

  resources :wills
  get 'wills/details/:will', to: 'wills#details', as: :details_will
  
  resources :trusts
  get 'trusts/details/:trust', to: 'trusts#details', as: :details_trust

  resources :attorneys
  get 'attorneys/details/:attorney', to: 'attorneys#details', as: :details_attorney, :defaults => {:attorney => 1}

  resources :trusts
  
  resources :categories
  resources :shares
  get '/folders/new/(:parent_id)', to: 'folders#new', as: :new_folder

  resources :documents

  resource :account, only: [:update, :show] do
    collection do
      get :setup
      post :send_code
      put :send_code
      post :verify_code
      put :verify_code
    end
  end

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
