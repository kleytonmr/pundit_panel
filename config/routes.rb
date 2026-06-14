PunditPanel::Engine.routes.draw do
  root to: "permissions#index"

  resources :permissions, only: [:index] do
    collection do
      patch :toggle
      patch :update_permission, action: :update
    end
  end

  resources :users, only: [:index] do
    member do
      patch :update_role
    end
  end
end
