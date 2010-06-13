if Rails.env == 'production'
  FLICKR_KEY = ENV['FLICKR_KEY']
  FLICKR_SECRET = ENV['FLICKR_SECRET']
else
  FLICKR_KEY = ENV['F4T_FLICKR_KEY']
  FLICKR_SECRET = ENV['F4T_FLICKR_SECRET']
end

FLICKR = {
  :key => FLICKR_KEY,
  :secret => FLICKR_SECRET
}
# FLICKR = YAML.load_file(File.join(RAILS_ROOT,'config/flickr.yml'))