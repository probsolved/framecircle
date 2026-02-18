Rails.application.routes.draw do
  devise_for :users

  root "groups#index"

  get "/groups/discover", to: "groups#discover", as: :discover_groups

  resource :account, only: [ :show, :edit, :update ], controller: "accounts"
  get "/u/:id", to: "profiles#show", as: :profile

  resources :groups, param: :slug do
    resources :members, only: [ :index ], controller: "group_members"

    patch "transfer_ownership/:user_id",
          to: "group_management#transfer_ownership",
          as: :transfer_ownership

    resources :invitations, only: [ :create ]

    resources :weeks, only: [ :show, :create ] do
      resource :submission, only: [ :show, :create, :update ]
    end

    resource :manage, only: [ :show, :update ], controller: "group_management"

    resources :memberships, only: [ :create, :destroy, :update ], controller: "group_memberships"
  end

  # ------------------------------------------------------------
  # Invitations (secure token links + legacy numeric redirect)
  # ------------------------------------------------------------

  get "/invitations/:id",
      to: "invitations#legacy_show",
      constraints: { id: /\d+/ }

  resources :invitations, param: :token, only: [ :show ] do
    post :accept, on: :member
  end

  resources :submissions, only: [] do
    resources :comments, only: [ :create ] do
      resources :comment_kudos, only: [ :create ], path: "kudos"
      delete "kudos/:kind", to: "comment_kudos#destroy", as: :kudo
    end

    resource :vote, only: [ :create, :update, :destroy ]
  end

  resources :photos, only: [ :destroy ]

  namespace :admin do
    resources :groups, only: [ :index, :destroy ]
    resources :users,  only: [ :index, :show, :edit, :update, :destroy ]
  end

  resource :terms_acceptance, only: [ :show, :update ]
end
