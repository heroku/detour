Detour::Engine.routes.draw do
  get  "/flags/:flaggable_type" => "flags#index", as: "flags"
  post "/flags/:flaggable_type" => "flags#update"

  resources :features, only: [:create, :destroy]
  resources :groups, only: [:index, :show, :create, :update]
  resources :memberships, only: [:create]

  get    "/flag-ins/:feature_name/:flaggable_type"     => "flaggable_flags#index",   as: "flag_in_flags"
  post   "/flag-ins/:feature_name/:flaggable_type"     => "flaggable_flags#create"
  delete "/flag-ins/:feature_name/:flaggable_type/:id" => "flaggable_flags#destroy", as: "flag_in_flag"

  get    "/opt-outs/:feature_name/:flaggable_type"     => "flaggable_flags#index",   as: "opt_out_flags"
  post   "/opt-outs/:feature_name/:flaggable_type"     => "flaggable_flags#create"
  delete "/opt-outs/:feature_name/:flaggable_type/:id" => "flaggable_flags#destroy", as: "opt_out_flag"

  root to: "application#index"
end
