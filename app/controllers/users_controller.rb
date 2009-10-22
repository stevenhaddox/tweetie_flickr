class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:create]
  
  def index
    @users = User.all
  end

  def show
    @user = User.find_by_twitter_username(params[:twitter_username])
#    @user = User.find(params[:id])
  end
  
  def new
    @user = User.new
  end
  
  def edit
    @user = User.find_by_twitter_username(params[:twitter_username])
#    @user = User.find(params[:id])
    @flickr = Flickr.new(FLICKR) # FLICKR.merge(:token => flickr_token)
  end
  
  def create
    # convert the flickr_username to their flickr_user_id
    flickr_username = params[:user][:flickr_user_id]
    flickr_id = convert_user_flickrname_to_id(flickr_username)
    params[:user][:flickr_user_id] = flickr_id unless flickr_id.blank?
    @user = User.create(params[:user])
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
