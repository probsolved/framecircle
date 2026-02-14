Rails.application.routes.draw do
  devise_for :users

  root "groups#index"

  # Profile / account
  resource :account, only: [ :show, :edit, :update ], controller: "accounts"
  get "/u/:id", to: "profiles#show", as: :profile

  resources :groups, param: :slug do
    # Group member directory page
    resources :members, only: [ :index ], controller: "group_members"

    # Create invite links for a group
    resources :invitations, only: [ :create ]

    # Weekly challenge + submission
    resources :weeks, only: [ :show, :create ] do
      resource :submission, only: [ :show, :create, :update ]
    end

    # Group management (edit name + members)
    resource :manage, only: [ :show ], controller: "group_management"
    resources :memberships, only: [ :create, :destroy ], controller: "group_memberships"
  end

  # Accept an invite link (landing page)
  resources :invitations, only: [ :show ]

  resources :submissions, only: [] do
    resources :comments, only: [ :create ]
    resource :vote, only: [ :create, :update, :destroy ]
  end

  resources :photos, only: [ :destroy ]
end
