Fest::Application.routes.draw do
  # Authentication stuff
  devise_for :users

  # Public stuff
  resources :festivals, only: [:index, :show] do
    post :reset_rankings, on: :member
    post(:random_priorities, on: :member) if !Rails.env.production?
    post :reset_screenings, on: :member
    resource :subscription, path: 'assistant', controller: :subscriptions,
             only: [:show, :update]
    match 'priorities' => "picks#index"
  end
  resources :films, only: [] do
    resources :picks, only: [:create]
  end
  resources :screenings, only: [:show]
  match 'ratings/:id' => 'user_ratings#show', as: :old_user_ratings

  resources :users, only: [] do
    resources :calendar, controller: :user_calendars, only: [:show]
    resources :ratings, controller: :user_ratings, only: [:show]
  end

  resources :announcements, only: [:index, :show] do
    post :clear, on: :collection
  end
  resources :questions, only: [:new, :create]

  root to: "home#landing"
  match 'changes' => "home#changes", as: :changes
  match 'feedback' => "questions#new", as: :feedback
  match 'help' => "home#help", as: :help
  match 'maintenance' => "home#maintenance", as: :maintenance
  match 'sign_ups_off' => "home#sign_ups_off", as: :sign_ups_off
  match 'welcome' => "home#index", as: :welcome

  resources :preferences, only: [:update]

  # Admin stuff
  match 'admin' => "home#admin", as: :admin_root
  namespace 'admin' do
    resources :festivals, only: [:show, :new, :create, :edit, :update, :destroy] do
      resources :films, only: [:index, :new, :create]
      resources :users, only: [:index], controller: :users
    end
    resources :films, only: [:show, :edit, :update, :destroy] do
      resources :screenings, only: [:new, :create]
    end
    resources :screenings, only: [:edit, :update, :destroy]

    resources :locations do
      resources :venues, only: [:new, :create]
    end
    resources :venues, only: [:edit, :update, :destroy]

    resources :users do
      post :act_as, on: :member
      resources :activity, only: [:index]
    end
    resources :enabled_flags, :only => [:update]
    resources :announcements, only: [:new, :create, :edit, :update, :destroy]
    resources :questions, only: [:index, :show, :edit, :update, :destroy]
    resources :activity, only: [:index]
  end
end
