ActionController::Routing::Routes.draw do |map|
  map.root :controller => :photos

  map.resources :photos

  map.resources :users, :except => [:show,:edit]
  map.user '/users/:twitter_username.:format', :controller => :users, :action => :show
  map.edit_user '/users/:twitter_username/edit', :controller => :users, :action => :edit

  map.flickr_callback '/callbacks/flickr', :controller => :users, :action => :flickr_callback
  map.resource :session
  map.finalize_session 'session/finalize', :controller => :sessions, :action => :finalize  
  map.login '/login', :controller => :sessions, :action => :new
  map.logout '/logout', :controller => :sessions, :action => :destroy

  map.tweetie_endpoint '/clients/:client/:client_hash.:format', :controller => :photos, :action => :create

  map.root :controller => :photos
  
end
