class PagesController < ApplicationController
  
  PAGES = ['index','join']

  def index
    f4t_search = Twitter::Search.new.from('flickr4tw1tter')
    @recent_tweets = f4t_search.map { |result| {:tweet=>result.text,:date=>result.created_at} }
    
    # render the landing page
  end

  def show
    render :action => params[:page]
  end

end
