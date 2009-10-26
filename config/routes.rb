ActionController::Routing::Routes.draw do |map|
  
  map.resources :photos
  map.resources :users, :except => [:show,:edit]
  map.user '/users/:twitter_username.:format', :controller => :users, :action => :show
  map.edit_user '/users/:twitter_username/edit', :controller => :users, :action => :edit

  map.flickr_callback '/callbacks/flickr', :controller => :users, :action => :flickr_callback
  map.resource :session
  map.finalize_session 'session/finalize', :controller => :sessions, :action => :finalize  
  map.login '/login', :controller => :sessions, :action => :new
  map.logout '/logout', :controller => :sessions, :action => :destroy

  map.client_endpoint '/clients/:client/:client_hash.:format', :controller => :photos, :action => :create

  map.root :controller => :pages
  map.page ':page', :controller => :pages, :action => 'show', :page => PagesController::PAGES 
  
end
