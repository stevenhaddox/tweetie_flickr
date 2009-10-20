class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:create]
  
  def index
    @users = User.all
  end
  
  def new
    @user = User.new
  end
  
  def create
    # logger.debug params[:user[:flickr_user_id]]
    # convert_user_flickrname_to_id
    # return @user
  end
  
private
  def convert_user_flickrname_to_id
    # @user.flickr_user_id = @user.get_flickr_id(params[:user[:flickr_user_id]])
  end
  
end