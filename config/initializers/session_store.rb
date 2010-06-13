# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
if Rails.env.production?
  secret = ENV['SECRET']
else
  secret = File.read(File.join(RAILS_ROOT, 'config/secret')).strip
  secret = ENV['F4T_SECRET'] unless secret
end

ActionController::Base.session = {
  :key         => '_flickr4twitter_session',
  :secret      => secret
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
