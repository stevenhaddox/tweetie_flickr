class PagesController < ApplicationController
  
  PAGES = ['index','join','join_tweetie','join_web_interface']

  def index
    begin
      f4t_search = Twitter::Search.new.from('flickr4tw1tter')
      @recent_tweets = f4t_search.map { |result| {:tweet=>result.text,:date=>result.created_at} }
    rescue
      # nothing, just don't want to blow up if we can't retrieve our current twitter status
    end
    
    # render the landing page
    respond_to do |format|
      # format.iphone # index.iphone.erb
      format.html # index.rhtml
    end
  end

  def show
    if PAGES.include?(params[:page])
      render :action => params[:page]
    else
      redirect_to '/404.html'
    end
  end

end
