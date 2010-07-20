class SessionsController < ApplicationController
  before_filter :_authenticate_oauth_echo
  
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
    # don't authenticate if we have a current_user
    if current_user.blank?
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
    end
    
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

end

