require 'sidekiq/web'

Rails.application.routes.draw do
  namespace :organization do
    resources :departments
  end
  authenticate :admin do
    mount Sidekiq::Web => "/sidekiq"
  end

  resources :locations
  get "dashboard/admin", as: :admin_dashboard
  get "dashboard/user", as: :user_dashboard
  get "dashboard/applicant", as: :applicant_dashboard
  resources :organizations
  devise_for :users, controllers: {
    sessions: "user/sessions",
    registrations: "user/registrations",
    passwords: "user/passwords",
    confirmations: "user/confirmations",
    unlocks: "user/unlocks"
  }
  devise_for :admins, controllers: {
    sessions: "administrator/admin/sessions",
    registrations: "administrator/admin/registrations",
    passwords: "administrator/admin/passwords",
    confirmations: "administrator/admin/confirmations",
    unlocks: "administrator/admin/unlocks"
  }
  root "public#home"
  get "public/about"
  get "public/contact"
  get "public/privacy"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  namespace :webhooks do
    post "datapass", to: "datapass#create"
    post "checkr", to: "checkr#create"
    post "fullschedule", to: "fullschedule#create"
    post "datapass_test", to: "datapass_test#create"
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
