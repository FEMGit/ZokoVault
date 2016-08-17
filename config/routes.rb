Rails.application.routes.draw do
  resources :vendor_accounts
  resources :vendors
  resources :contacts
  devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root to: 'welcome#index'
  get 'files' => 'welcome#files'
  get 'filestacktest' => 'welcome#filestacktest'
  get 'styleguide' => 'welcome#styleguide'

  # Default category pages ?Could probably be done better programatically?
  get 'estate_planning' => 'categories#estate_planning'
  get 'final_wishes' => 'categories#final_wishes'
  get 'financial_information' => 'categories#financial_information'
  get 'healthcare_choices' => 'categories#healthcare_choices'
  get 'insurance' => 'categories#insurance', as: 'insurance'
  get 'shared' => 'categories#shared'
  get 'taxes' => 'categories#taxes'
  get 'web_accounts' => 'categories#web_accounts'

  get 'shares/new/:document' => 'shares#new'

  resources :users

  Rails.application.routes.draw do
  resources :vendor_accounts
  resources :vendors
  resources :contacts
    resources :categories
    resources :shares

    resources :folders, except: [:index, :new] do
      resources :documents, except: [:index]
    end
    get '/folders/new/(:parent_id)', to: 'folders#new', as: :new_folder

    resources :documents, only: [:index]
  end

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
