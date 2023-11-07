# frozen_string_literal: true

Rails.application.routes.draw do
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  mount Blacklight::Oembed::Engine, at: 'oembed'
  mount Riiif::Engine => '/images', as: 'riiif'

  root to: 'spotlight/exhibits#index'

  mount Spotlight::Engine, at: 'spotlight'
  mount Blacklight::Engine => '/'
  #  root to: "catalog#index" # replaced by spotlight root path
  concern :searchable, Blacklight::Routes::Searchable.new

  # Compatibility with old UMedia JSON views, override what Rails/Blacklight want to do with JSON
  get '/catalog/:id.json', controller: 'catalog', action: 'raw'
  get '/item/:id.json', controller: 'catalog', action: 'raw'
  # Calling /item with no doc id is a fault
  get '/item', controller: 'catalog', action: 'bad_request_no_search'

  # For compatibility catalog show pages aliased as /item/:id
  # (must be after the raw .json route so this does not supercede it)
  get '/item/:id', to: 'catalog#show'


  # Finally allow Blacklight to do its normal stuff
  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
  end

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

  resources :iiif, only: [] do
    member do
      get :manifest, action: 'show'
      get :search
      get :autocomplete
    end
  end

  # Sidekiq Web
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
