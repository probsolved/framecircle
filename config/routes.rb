# config/routes.rb
Rails.application.routes.draw do
  devise_for :users

  # Start here now that Bootstrap is confirmed
  root "groups#index"

  resources :groups, param: :slug do
    resources :invitations, only: [ :create ]

    resources :weeks, only: [ :show, :create ] do
      resource :submission, only: [ :show, :create, :update ]
    end

    # Group management (edit name + members)
    resource :manage, only: [ :show ], controller: "group_management"
    resources :memberships, only: [ :create, :destroy ], controller: "group_memberships"
  end

  resources :invitations, only: [ :show ] # accept via token landing page
# config/routes.rb
resources :group_invitations, only: [ :show ], controller: "invitations"


  resources :submissions, only: [] do
    resources :comments, only: [ :create ]
    resource :vote, only: [ :create, :update, :destroy ]
  end

  resources :photos, only: [ :destroy ]
end
