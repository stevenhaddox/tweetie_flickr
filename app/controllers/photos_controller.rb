class PhotosController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:create]
  before_filter :check_login, :only => [:new]
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
    @is_xml = format_is_xml?(params[:format])
    # verify we have a valid authenticated user by current_user session 
    # OR lookup username by custom_client_hash (multiple tweetie accounts) or client_hash
    if @is_xml==true
      unless params[:username] && params[:client_hash]
        render :xml => '<?xml version="1.0" encoding="UTF-8"?><errors><error>Invalid Credentials</error></errors>' and return
      end
      tmp_user = User.find_by_twitter_username(params[:username])
      if tmp_user
        @user = tmp_user.custom_client_hash.blank? ? User.find_by_twitter_username_and_client_hash(params[:username],params[:client_hash]) : User.find_by_twitter_username_and_custom_client_hash(params[:username],params[:client_hash])
        tmp_user=nil # I don't like keeping users around... even in temporary variables
      end
    else
      if current_user
        @user = @is_xml==true ? nil : current_user
      end
    end
        
    unless @user
      if @is_xml==true
        render :xml => '<?xml version="1.0" encoding="UTF-8"?><errors><error>Invalid Credentials</error></errors>' and return
      else
        redirect_to '/403.html' and return
      end
    end

    # make sure our user is authenticated with Flickr
    unless @user.flickr_token
      if @is_xml==true
        render :xml => '<?xml version="1.0" encoding="UTF-8"?><errors><error>Invalid Credentials</error></errors>' and return
      else
        redirect_to edit_user_path(@user) and return
      end      
    end

    # create a photo instance params hash if sent via a client
    unless params[:photo]
      params[:photo]={}
      params[:photo][:caption] = params[:message]
      params[:photo][:image] = params[:media]
    end
    
    # create the new photo
    @photo = @user.photos.new(params[:photo])

    respond_to do |format|
      if @photo.save
        if current_user
          message = params[:photo][:caption]
          if @photo.short_url
            message = message.blank? ? "#{@photo.short_url}" : message + " #{@photo.short_url}"
            @photo.update_attribute(:caption, message)
            tweet = current_user.client.update(message)
          end          
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
  end
end

private
  def format_is_xml?(format=nil)
    return nil if format.blank?
    return format=='xml' ? true : nil
  end

  def check_login
    _authenticate_oauth_echo unless current_user
    return true if current_user
    redirect_to login_path #redirect to a non SSL page to ensure we don't throw an error
  end

  def _authenticate_oauth_echo
    require 'httparty'
    # header auth only for now; also lock down the auth provider endpoint so we can't spoof
    if(request.env["HTTP_X_AUTH_SERVICE_PROVIDER"] != 'https://api.twitter.com/1/account/verify_credentials.json' || request.env["HTTP_X_AUTH_SERVICE_PROVIDER"].blank?)
      return false
    else
      auth_service_provider = request.env["HTTP_X_AUTH_SERVICE_PROVIDER"]
      verify_credentials_authorization = request.env["HTTP_X_VERIFY_CREDENTIALS_AUTHORIZATION"]
    end

    auth_response = HTTParty.get(auth_service_provider, :format => :json, :headers => {'Authorization' => verify_credentials_authorization}) rescue nil
    if !auth_response['screen_name'].blank?
      current_user = User.find(:first, :conditions => {:login => auth_response['screen_name']})
      return current_user
    end
    logger.info(auth_response)
    return false
  end
