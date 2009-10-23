class UsersController < ApplicationController
  before_filter :authenticate, :except => [:index, :show]
  before_filter :get_user, :only => [:show, :edit, :update]
  before_filter :set_flickr, :only => [:show, :edit, :update, :flickr_callback]
  before_filter :check_flickr_auth, :except => [:new, :create, :edit, :update, :flickr_callback]
  skip_before_filter :verify_authenticity_token, :only => [:create]
 
  def index
    @users = User.all
  end

  def show
  end
  
  def new
    @user = User.new
  end
  
  def edit
    if self? != true 
      flash[:error] = "Editing another user's profile is not allowed." 
      redirect_to users_path and return false
    end
  end

  def update
    # convert the flickr_username to their flickr_user_id
    unless params[:user][:flickr_user_id]
      flash[:error] = 'You must provide your Flickr screenname to lokup your ID'
      render :action => :edit and return false
    end
    flickr_username = params[:user][:flickr_user_id]
    flickr_id = convert_user_flickrname_to_id(flickr_username)
    unless flickr_id && flickr_id.include?('@')
      flash[:error] = "There was an error looking up your ID"
      render :action => :edit and return false
    end
    params[:user][:flickr_user_id] = flickr_id
    @user.update_attributes(params[:user])
    unless @user.flickr_token
      redirect_to @flickr.auth.url(:write) and return
    else      
      respond_to do |format|
        format.html { redirect_to user_path(@user) }
      end
    end
  end

  def flickr_callback
    flickr = Flickr.new(FLICKR)
    flickr.auth.frob = params[:frob]
    current_user.update_attribute :flickr_token, flickr.auth.token.token
    respond_to do |format|
      format.html { redirect_to user_path(current_user) }
    end
  end
  
private
  def get_user
    unless params[:twitter_username] or params[:id]
      flash[:error]='You must provide a username.'
      redirect_to users_path and return false
    end
    twitter_username = params[:twitter_username]
    twitter_username ||= params[:id]
    @user = User.find_by_twitter_username(twitter_username)
    unless @user
      flash[:error] = 'We could not locate that user.'
      redirect_to users_path and return false
    end
  end

  def self?
    if current_user == @user
      return true
    else
      return false
    end
  end
  
  def set_flickr
    if current_user.flickr_token
      @flickr = Flickr.new(FLICKR.merge(:token => current_user.flickr_token))
    else
      @flickr = Flickr.new(FLICKR)
    end
  end
  
  def check_flickr_auth
    return unless current_user
    unless current_user.flickr_token && current_user.flickr_user_id
      redirect_to edit_user_path(current_user) and return
    end
  end

  def convert_user_flickrname_to_id(flickr_username)
    User.get_flickr_id(flickr_username)
  end
  
end
