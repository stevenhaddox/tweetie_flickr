namespace :config do
  desc 'Initialize application config files'
  task :init do
    Rake::Task["config:flickr"].invoke
    Rake::Task["config:twitter"].invoke
  end
  
  desc 'Generate flickr.yml config file'
  task :flickr do
    if Rails.env == 'production'
      FLICKR_KEY = ENV['FLICKR_KEY']
      FLICKR_SECRET = ENV['FLICKR_SECRET']
    else
      FLICKR_KEY = ENV['F4T_FLICKR_KEY']
      FLICKR_SECRET = ENV['F4T_FLICKR_SECRET']
    end
    File.open("#{Rails.root}/config/flickr.yml", 'w+') do |file|
flickr_config = <<-END_FLICKR
key: #{FLICKR_KEY}
secret: #{FLICKR_SECRET}
END_FLICKR
      file.write flickr_config
    end
  end

  desc 'Generate twitter.yml config file'
  task :twitter do
    if Rails.env == 'production'
      TWITTER_TOKEN = ENV['TWITTER_TOKEN']
      TWITTER_SECRET = ENV['TWITTER_SECRET']
    else
      TWITTER_TOKEN = ENV['F4T_TWITTER_TOKEN']
      TWITTER_SECRET = ENV['F4T_TWITTER_SECRET']
    end
    File.open("#{Rails.root}/config/twitter.yml", 'w+') do |file|
twitter_config = <<-END_TWITTER
token: #{TWITTER_TOKEN}
secret: #{TWITTER_SECRET}
END_TWITTER
      file.write twitter_config
    end
  end

  desc 'Push _local_ ENV config settings to heroku'
  task :heroku do
    ENV_VARS = {
      'FLICKR_KEY' => ENV['F4T_FLICKR_KEY'],
      'FLICKR_SECRET' => ENV['F4T_FLICKR_SECRET'],
      'SECRET' => File.read("#{Rails.root}/config/secret"),
      'TWITTER_TOKEN' => ENV['F4T_TWITTER_TOKEN'],
      'TWITTER_SECRET' => ENV['F4T_TWITTER_SECRET']
    }
    command = "heroku config:add"
    ENV_VARS.each {|key, val| command << " #{key}=#{val} " if val }
    system command
  end  
  
end

# heroku config:add TWITTER_TOKEN=token_str TWITTER_SECRET=secret_str
