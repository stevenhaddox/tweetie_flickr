class ApplicationController < ActionController::Base
  include Twitter::AuthenticationHelpers

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :twitter_password

  rescue_from Twitter::Unauthorized, :with => :force_sign_in
  
private
  def force_sign_in(exception)
    reset_session
    flash[:error] = 'Seems your credentials are not good anymore. Please sign in again.'
    redirect_to new_session_path
  end
end
