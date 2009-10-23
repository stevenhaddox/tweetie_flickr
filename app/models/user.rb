# == Schema Information
#
# Table name: users
#
#  id               :integer         not null, primary key
#  twitter_username :string(255)
#  twitter_password :string(255)
#  twitter_rtoken   :string(255)
#  twitter_rsecret  :string(255)
#  photo_hash       :string(255)
#  flickr_user_id   :string(255)
#  flickr_token     :string(255)
#  test_user        :boolean
#  created_at       :datetime
#  updated_at       :datetime
#

require 'uuid'
class User < ActiveRecord::Base
  has_many :photos, :dependent => :destroy

  def to_param
    twitter_username
  end

  # TODO: Convert to OAuth    
  # def self.twitter_auth(username, password)
  def self.twitter_auth(username)
    User.find_by_twitter_username(username)
  end
  
  # return Twitter API object
  def twitter_api
    # httpauth = Twitter::HTTPAuth.new(twitter_username, twitter_password)
    # Twitter::Base.new(httpauth)
    oauth = Twitter::OAuth.new(TWITTER['token'], TWITTER['secret'])
    Twitter::Base.new(oauth)
  end
  memoize :twitter_api

  def self.get_flickr_id(flickr_username)
    flickr_api = Flickr.new(FLICKR) # FLICKR.merge(:token => flickr_token)
    p = flickr_api.people.find_by_username(flickr_username)
    p.nsid
  end
  
  def photo_hash=(oauth_verification_str=nil)
    return unless read_attribute(:photo_hash).blank? or oauth_verification_str.blank?
    if oauth_verification_str.blank?
      write_attribute(:photo_hash, nil)
      return
    end
    oauth_uuid_string = "#{oauth_verification_str}+#{UUID.new}".hash.abs
    write_attribute(:photo_hash, oauth_uuid_string)
  end 
   
  def get_endpoint_path
    "/clients/tweetie/#{photo_hash}.xml" 
  end  
end
