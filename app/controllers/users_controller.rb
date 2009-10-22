class UsersController < ApplicationController
  before_filter :authenticate, :except => [:index, :show]
  skip_before_filter :verify_authenticity_token, :only => [:create]
  
  def index
    @users = User.all
  end

  def show
    @user = User.find_by_twitter_username(params[:twitter_username])
    unless @user.flickr_token
      redirect_to edit_user_path 
    end
  end
  
  def new
    @user = User.new
  end
  
  def edit
    @user = User.find_by_twitter_username(params[:twitter_username])
    @flickr = Flickr.new(FLICKR) # FLICKR.merge(:token => flickr_token)
  end

  def update
    # convert the flickr_username to their flickr_user_id
    flickr_username = params[:user][:flickr_user_id]
    flickr_id = convert_user_flickrname_to_id(flickr_username)
    params[:user][:flickr_user_id] = flickr_id unless flickr_id.blank?
    @user = User.update_attributes(params[:user])
    respond_to do |format|
      if @user.valid?
        @user.save
        format.html { redirect_to user_path(@user) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
private
  def convert_user_flickrname_to_id(flickr_username)
    User.get_flickr_id(flickr_username)
  end
  
end
