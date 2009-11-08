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
    @is_xml = format_is_xml?(params[:format])
    logger.debug "Request.format_is_xml?: #{@is_xml}"
    # verify we have a valid authenticated user by current_user session 
    # OR lookup username by custom_client_hash (multiple tweetie accounts) or client_hash
    if @is_xml==true
      unless params[:username] && params[:client_hash]
        render :xml => '<?xml version="1.0" encoding="UTF-8"?><errors><error>Invalid Credentials</error></errors>' and return
      end
      tmp_user = User.find_by_twitter_username(params[:username])
		logger.debug "Found tmp_user: #{tmp_user.twitter_username}"
      if tmp_user
        @user = tmp_user.custom_client_hash.blank? ? User.find_by_twitter_username_and_client_hash(params[:username],params[:client_hash]) : User.find_by_twitter_username_and_custom_client_hash(params[:username],params[:client_hash])
        tmp_user=nil # I don't like keeping users around... even in temporary variables
      end
    else
      if current_user
        @user = @is_xml==true ? nil : current_user
      end
    end
    
    logger.debug "@user: Nil? #{@user.blank?} - #{@user.id}: #{@user.twitter_username}"
    
    unless @user
      if @is_xml==true
        render :xml => '<?xml version="1.0" encoding="UTF-8"?><errors><error>Invalid Credentials</error></errors>' and return
      else
        redirect_to '/403.html' and return
      end
    end

    # make sure our user is authenticated with Flickr
    unless @user.flickr_token
		logger.debug "NO FLICKR TOKEN!!!"    
      if @is_xml==true
        render :xml => '<?xml version="1.0" encoding="UTF-8"?><errors><error>Invalid Credentials</error></errors>' and return
      else
        redirect_to edit_user_path(@user) and return
      end      
    end

    # create a photo instance params hash if sent via a client
    unless params[:photo]
      params[:photo]={}
logger.debug "params[:photo][:caption]: #{params[:message]}"      
      params[:photo][:caption] = params[:message]
logger.debug "params[:photo][:image]: #{params[:media].blank?}"
      params[:photo][:image] = params[:media]
    end
    
	 logger.debug "params[:photo]: #{params[:photo].inspect}"    
    # create the new photo
    @photo = @user.photos.new(params[:photo])

    logger.debug '-'*80
    logger.debug @photo.errors.inspect

    respond_to do |format|
      if @photo.save
		  logger.debug '*'*80
		  logger.debug "Photo Saved: #{@photo.inspect}"
        if current_user
          message = params[:photo][:message]
          if @photo.short_url
            message += " #{@photo.short_url}"
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