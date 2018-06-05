Rails.application.routes.draw do

   root               'static_pages#home'
   get '/help'     => 'static_pages#help'
   get '/about'    => 'static_pages#about'
   get '/contact'  => 'static_pages#contact'
   get '/signup'   => 'users#new'
   # 例)getメソッドで "aaaa.com/signup"みたいなURLが飛んできたらuserコントローラーのnewアクションが走る。

   get    '/login'   => 'sessions#new'
   post   '/login'   => 'sessions#create'
   delete '/logout'  => 'sessions#destroy'

   resources :users do
     # /users/:id/followingと
     # /users/:id/followersが欲しい。
     member do
       get :following, :followers
     end
   end

    #    users  　　　GET    /users(.:format)          　　          　users#index
    #           　　　POST   /users(.:format)          　　　          users#create
    # new_user  　　　GET    /users/new(.:format)      　　　　　       users#new
    # edit_user 　　　GET    /users/:id/edit(.:format)                users#edit
    #     user  　　　GET    /users/:id(.:format)      　　　　　　　　　users#show
    #           　　　PATCH  /users/:id(.:format)                     users#update
    #           　　　PUT    /users/:id(.:format)                     users#update
    #           　　　DELETE /users/:id(.:format)      　　　　　　　　 users#destroy
    # following_user GET    /users/:id/following(.:format)          users#following
    # followers_user GET    /users/:id/followers(.:format)          users#followers

    # collection do だと
    # following_users GET    /users/following(.:format)              users#following
    # followers_users GET    /users/followers(.:format)              users#followers

   resources :account_activations, only: [:edit]
   # edit_account_activation GET    /account_activations/:id<token>/edit(.:format) account_activations#edit

   resources :password_resets, only: [:new, :create, :edit, :update]
   resources :microposts, only: [:create, :destroy]
   resources :relationships, only: [:create, :destroy]
 end
