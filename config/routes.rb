Rails.application.routes.draw do
  devise_for :users

  root "groups#index"

  # Profile / account
  resource :account, only: [ :show, :edit, :update ], controller: "accounts"
  get "/u/:id", to: "profiles#show", as: :profile

  resources :groups, param: :slug do
    # Group member directory page
    resources :members, only: [ :index ], controller: "group_members"
    patch "transfer_ownership/:user_id", to: "group_management#transfer_ownership", as: :transfer_ownership

    # Create invite links for a group
    resources :invitations, only: [ :create ]

    # Weekly challenge + submission
    resources :weeks, only: [ :show, :create ] do
      resource :submission, only: [ :show, :create, :update ]
    end

    # Group management (edit name + members)
    resource :manage, only: [ :show ], controller: "group_management"
    resources :memberships, only: [ :create, :destroy, :update ], controller: "group_memberships"
  end

  # Accept an invite link (landing page)
  resources :invitations, only: [ :show ]

  resources :submissions, only: [] do
  resources :comments, only: [ :create ] do
    resources :comment_kudos, only: [ :create ], path: "kudos"
    delete "kudos/:kind", to: "comment_kudos#destroy", as: :kudo
  end

  resource :vote, only: [ :create, :update, :destroy ]
end


  resources :photos, only: [ :destroy ]

  namespace :admin do
    resources :groups, only: [ :index ]
    resources :users, only: [ :index, :show, :edit, :update, :destroy ]
  end

  resource :terms_acceptance, only: [ :show, :update ]
end
