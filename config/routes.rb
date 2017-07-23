Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'application#index'

  get 'item_terms',      to: 'application#item_terms'
  get 'item_term_urls',  to: 'application#item_term_urls'
  get 'item_main_terms', to: 'application#item_main_terms'
  get 'url',             to: 'application#url'
end
