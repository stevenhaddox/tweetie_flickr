class PagesController < ApplicationController
  
  PAGES = ['index','join','join_tweetie','join_web_interface']

  def index
    f4t_search = Twitter::Search.new.from('flickr4tw1tter')
    @recent_tweets = f4t_search.map { |result| {:tweet=>result.text,:date=>result.created_at} }
    
    # render the landing page
  end

  def show
    if PAGES.include?(params[:page])
      render :action => params[:page]
    else
      redirect_to '/404.html'
    end
  end

end
