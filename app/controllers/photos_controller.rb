class PhotosController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:create]
  ssl_required :new, :create unless Rails.env.development?
  
  def index
    @photos = Photo.paginate :page => params[:page], :order => 'created_at DESC'
  end

  def show
    @photo = Photo.find(params[:id])
    @recent_photos = Photo.find(:all, :conditions=>{:user_id=>@photo.user_id}, :limit=>4, :order=>'created_at DESC')
  end
  
  def new
    @photo ||= Photo.new # application_controller may already define this
  end
  
  # POST /photos.xml
  def create
    # verify we have a valid authenticated user by current_user session 
    # OR lookup username by custom_client_hash (multiple tweetie accounts) or client_hash
    unless current_user
      unless params[:username] && params[:client_hash] 
        redirect_to '/403.html' and return false
      end
      @user = User.find_by_twitter_username_and_custom_client_hash(params[:username],params[:client_hash])
      @user ||= User.find_by_twitter_username_and_client_hash(params[:username],params[:client_hash])
    else
      @user = current_user
      @user = nil if params[:format] && params[:format]=='xml'
    end
    redirect_to '/403.html' and return false unless @user

    if @user
      return unless @user.flickr_token

      @photo = @user.photos.new(params[:photo])
      @photo.image = params[:media] if params[:media]
      
      respond_to do |format|
        if @photo.save
          if current_user && params[:photo]
            message = params[:photo][:message]
            message += " #{@photo.short_url}"
            tweet = current_user.client.update(message) if @photo.short_url
            flash[:notice] = "Your tweet has been posted successfully"
          end
          # Fork and wait about some time to fetch the tweets -
          # This obviously would have been better to use a
          # background job but that would have cost money :)
          if @photo.caption.blank?
            pid = fork do
              # wait 1 minute
              sleep 60 
              Photo.connection.reconnect!
              # get 'clean' photo
              photo = Photo.find(@photo.id)
              photo.fetch_tweet
              exit
            end
            Process.detach(pid)
            Photo.connection.reconnect!
          end

          flash[:notice] ||= "Photo uploaded to Flickr"
          format.html { redirect_to(photos_url) }
          format.xml  { render :xml => @photo, :status => :created, :location => @photo }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
        end
      end
    else
      render :nothing => true
    end
  end
end
