MystroChef::Engine.routes.draw do
  resources :roles
  root to: "roles#index"
end

MystroServer::Application.routes.draw do
  mount MystroChef::Engine => "/plugins/chef"
end
