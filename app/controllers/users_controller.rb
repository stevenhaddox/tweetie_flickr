class UsersController < ApplicationController
  before_filter :authenticate, :except => [:index, :show]
  before_filter :get_user, :only => [:show, :edit, :update]
  before_filter :set_flickr, :only => [:show, :edit, :update, :flickr_callback]
  before_filter :check_flickr_auth, :except => [:new, :create, :edit, :update, :flickr_callback]
  skip_before_filter :verify_authenticity_token, :only => [:create]
 
  def index
    @users = User.paginate :page => params[:page], :order => :twitter_username
  end

  def show
    @photos = @user.photos.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 18
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
    if params[:user]
      if params[:user][:flickr_username]
        flickr_username = params[:user][:flickr_username].strip
        if flickr_username.match('/')
          flickr_username = flickr_username.gsub('http://flickr.com/people/','').gsub('/','')
        end
        unless flickr_username == @user.flickr_username
          new_flickr_id = check_flickr_user_id(flickr_username)
          if new_flickr_id.blank?
            params[:user].delete(:flickr_username)
          else
            params[:user][:flickr_user_id] = new_flickr_id
          end
        end
      end
      # either reset / update custom_client_hash - can't do both
      if params[:user][:reset_custom_client_hash].to_i == 1
        @user.update_attribute(:custom_client_hash, nil)
      else
        params[:user][:custom_client_hash]=params[:user][:new_custom_client_hash] if params[:user][:new_custom_client_hash]
      end

      @user.update_attributes(params[:user])
    end

    render :action => :edit and return false unless flash[:error].blank?
    unless @user.flickr_token
      redirect_to @flickr.auth.url(:write) and return
    else
      respond_to do |format|
        flash[:success]="Profile Updated Successfully"
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
    if current_user && current_user.flickr_token
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

  def check_flickr_user_id(flickr_username)
    # no need to update the flickr_user_id if it is the same
    if current_user.flickr_username == flickr_username
      return nil
    end
    begin 
      flickr_id = User.get_flickr_id(flickr_username)
    rescue 
      flash[:error] = "There was an error looking up your Flickr ID<br />
        Please verify you entered only your username seen in your Flickr profile URL:<br />
        http://flickr.com/people/<strong>username</strong>/"
      return
    end
    flickr_id
  end
  
end
