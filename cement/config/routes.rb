Cement::Application.routes.draw do



  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.


  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'


  root :to => 'users#welcome'

  resources :items do
      post 'remove', :on => :member
      get  'rep_txnitems', :on => :member
      get  'all_search', :on => :collection
      get  'edit_items_all', :on => :collection

      get  'aggrigated_summary', :on => :collection
      post 'filter_rep_txnitems', :on => :collection
      post 'set_default_date', :on => :collection
      post 'quick_save_item', :on => :collection
      get  'stock_entries', :on => :member
  end

  resources :contacts do
    post 'remove', :on => :member
    post  'reports', :on => :member
    post  'ajax_create', :on => :collection

    get 'search_names', :on => :collection
    get  'add_txn', :on => :collection
    get  'window_list', :on => :collection
    get  'report_page', :on => :member
    get 'excel_export', :on => :member

    get 'quick_edit' , :on => :collection
    get 'all_edit' , :on => :collection

    post 'quick_update' , :on => :collection
    post 'all_edit' , :on => :collection
    post 'save_filter', :on => :collection
    post 'filter', :on => :collection
    get  'show_filter', :on => :collection 
    
  end

  resources :transactions do
    post 'remove', :on => :member
    get  'add_item_row', :on => :collection
    post 'pagination', :on => :collection
    get  'quick_add_form', :on => :collection
    post 'quick_add', :on => :collection
  end

  resources :stock_entries do
    post 'remove', :on => :member
    get  'add_item_row', :on => :collection
    post 'pagination', :on => :collection
    get  'quick_add_form', :on => :collection
    post 'quick_add', :on => :collection
    get  'contact_stock', :on => :member
  end

  resources :sites do
    get  'window_list', :on => :collection
    get 'search_names', :on => :collection
    post 'remove', :on => :member
    get 'rep_txnitems', :on => :member
    get 'contact_txnitems', :on => :member
  end

  resources :transaction_types do
      post 'remove', :on => :member

    resources :custom_fields do
      get 'remove', :on => :member
    end  

  end  

  resources :users do
    post 'enter_in', :on => :collection
    get 'ask_signin', :on => :collection
    get 'change_password', :on => :member
    get 'activate', :on => :member
    get 'inactivate', :on => :member
    post 'remove', :on => :member
    put 'save_new_password', :on => :member
    get 'reset_password', :on => :member
    get 'logout', :on => :member
    get  'no_access', :on => :collection
    get  'self_details', :on => :member
  end  

  resources :payments do
      post 'remove', :on => :member
      get  'add_payment_row', :on => :collection
  end   

   resources :reports do
      post 'generate', :on => :collection
      get 'saved_message', :on => :member
      
   end 

   resources :analytics do
      get  'sort_baldtls', :on => :collection
      get  'sales', :on => :collection
      get  'sort_itemsales', :on => :collection
      post 'filter_block1', :on => :collection
      post 'filter_block2', :on => :collection
      post 'filter_block3', :on => :collection
      put  'filter_block1', :on => :collection
   end 

   get "status", to:"analytics#aggr_payments"

end
    
    

