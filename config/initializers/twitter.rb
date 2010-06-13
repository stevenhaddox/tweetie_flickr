if Rails.env.production?
  TWITTER_TOKEN = ENV['TWITTER_TOKEN']
  TWITTER_SECRET = ENV['TWITTER_SECRET']
else
  TWITTER_TOKEN = ENV['F4T_TWITTER_TOKEN']
  TWITTER_SECRET = ENV['F4T_TWITTER_SECRET']
end

TWITTER = {
  :token => TWITTER_TOKEN,
  :secret => TWITTER_SECRET
}

# TWITTER = YAML.load_file(File.join(RAILS_ROOT,'config/twitter.yml'))
