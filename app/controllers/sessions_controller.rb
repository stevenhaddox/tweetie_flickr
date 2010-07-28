class SessionsController < ApplicationController  
  def new
  end
  
  def create
    oauth.set_callback_url(finalize_session_url)
    
    session['rtoken']  = oauth.request_token.token
    session['rsecret'] = oauth.request_token.secret
    
    redirect_to oauth.request_token.authorize_url
  end
  
  def destroy
    reset_session
    redirect_to page_url
  end
  
  def finalize
    oauth.authorize_from_request(session['rtoken'], session['rsecret'], params[:oauth_verifier])
    
    session['rtoken']  = nil
    session['rsecret'] = nil
    
    profile = Twitter::Base.new(oauth).verify_credentials
    user    = User.find_or_create_by_twitter_username(profile.screen_name)
    
    user.update_attributes({
      :twitter_rtoken => oauth.access_token.token, 
      :twitter_rsecret => oauth.access_token.secret
    })

    user.update_attribute(:client_hash, params[:oauth_verifier].hash) if user.client_hash.nil?
    
    sign_in(user)

    if current_user.flickr_token && current_user.flickr_user_id
      redirect_to root_path
    else
      redirect_to edit_user_path(user)
    end
  end
  
  private
    def oauth
      @oauth ||= Twitter::OAuth.new(TWITTER['token'], TWITTER['secret'], :sign_in => true)
    end
end

