# == Schema Information
#
# Table name: users
#
#  id                   :integer         not null, primary key
#  twitter_username     :string(255)
#  twitter_rtoken       :string(255)
#  twitter_rsecret      :string(255)
#  custom_client_hash   :string(255)
#  client_hash          :string(255)
#  flickr_user_id       :string(255)
#  flickr_token         :string(255)
#  flickr_username      :string(255)
#  test_user            :boolean
#  created_at           :datetime
#  updated_at           :datetime
#

require 'uuid'
class User < ActiveRecord::Base
  has_many :photos, :dependent => :destroy

  attr_accessor :new_custom_client_hash, :reset_custom_client_hash

  def to_param
    twitter_username
  end

  # =================
  # = Class methods =
  # =================


  def self.get_flickr_id(flickr_username)
    flickr_api = Flickr.new(FLICKR) # FLICKR.merge(:token => flickr_token)
    p = flickr_api.people.find_by_username(flickr_username)
    p.nsid
  end

  # ====================
  # = Instance methods =
  # ====================

  def authorized?
    twiter_rtoken.present? && twitter_rsecret.present?
  end
  
  def oauth
    @oauth ||= Twitter::OAuth.new(TWITTER['token'], TWITTER['secret'])
  end
  
  delegate :request_token, :access_token, :authorize_from_request, :to => :oauth
  
  def client
    @client ||= begin
      oauth.authorize_from_access(twitter_rtoken, twitter_rsecret)
      Twitter::Base.new(oauth)
    end
  end



  def custom_client_hash=(custom_client_hash_str=nil)
    if custom_client_hash_str.blank?
      write_attribute(:custom_client_hash, nil)
      return
    end
    custom_client_hash = custom_client_hash_str.hash.abs
    write_attribute(:custom_client_hash, custom_client_hash)
  end
  
  def client_hash=(oauth_verification_str=nil)
    return unless read_attribute(:client_hash).blank? or oauth_verification_str.blank?
    if oauth_verification_str.blank?
      write_attribute(:client_hash, nil)
      return
    end
    oauth_uuid_string = "#{oauth_verification_str}+#{UUID.new}".hash.abs
    write_attribute(:client_hash, oauth_uuid_string)
  end 
   
  def get_endpoint_path
    url_client_hash = custom_client_hash.blank? ? client_hash : custom_client_hash
    "clients/tweetie/#{url_client_hash}.xml" 
  end  
end
