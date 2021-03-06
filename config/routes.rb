# frozen_string_literal: true

Rails.application.routes.draw do
  mount Blacklight::Oembed::Engine, at: 'oembed'
  mount Riiif::Engine => '/images', as: 'riiif'

  root to: 'spotlight/exhibits#index'
  # root to: 'catalog#index' # replaced by spotlight root path

  mount Spotlight::Engine, at: 'spotlight'
  mount Blacklight::Engine => '/'
  #  root to: "catalog#index" # replaced by spotlight root path
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  # For compatibility catalog show pages aliased as /item/:id
  get '/item/:id', to: 'catalog#show'

  devise_for :users
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable

    member do
      get 'transcript' => 'transcript#index'
    end
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  get 'robots.:format' => 'robots#robots'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # Sidekiq Web
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
