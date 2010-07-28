class ApplicationController < ActionController::Base
  include Twitter::AuthenticationHelpers
  before_filter :check_flickr_auth
  #before_filter :set_iphone_format

  include SslRequirement

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  rescue_from Twitter::Unauthorized, :with => :force_sign_in
  
private
  def force_sign_in(exception)
    reset_session
    flash[:error] = 'Seems your credentials have expired or are invalid. Please sign in again.'
    redirect_to new_session_path
  end
  
  # make sure that any authenticated in user has authenticated with flickr
  def check_flickr_auth
    return unless current_user
    exempt_controllers = ['sessions','users']
    unless current_user.flickr_token && current_user.flickr_user_id
      redirect_to edit_user_path(current_user) unless exempt_controllers.include?(params[:controller])
    end
  end

  # Request from an iPhone or iPod touch? (Mobile Safari user agent)
  def iphone_user_agent?
    request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)/]
  end


  def set_iphone_format
    request.format = :iphone if iphone_user_agent?
  end

end
