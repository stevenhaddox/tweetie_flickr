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
require 'nokogiri'
class User < ActiveRecord::Base
  has_many :photos, :dependent => :destroy

  attr_accessor :new_custom_client_hash, :reset_custom_client_hash
  cattr_reader :per_page
  @@per_page = 20
  
  def to_param
    twitter_username
  end

  # =================
  # = Class methods =
  # =================


  def self.get_flickr_id(flickr_username)
    # flickr_api = Flickr.new(FLICKR) # FLICKR.merge(:token => flickr_token)
    # flickr_username is _NOT_ the URL, but is the name displayed at the top of their profile page
    # e.g. NOT 'katiecupcake', but 'katie.cupcake'
    # begin
    #   p = flickr_api.people.find_by_username(flickr_username) 
    #   flickr_id = p.nsid
    # rescue
      # get their flickr user id from their Flickr profile icon image
      flickr_html = Nokogiri::HTML(open("http://flickr.com/people/#{flickr_username}"))
      id_img = flickr_html.css('.logo')
      y id_img.to_s
      id_img_src = id_img.attr('src').to_s
      regex = /#(.*)$/
      match = id_img_src.match(regex)
      flickr_id = match[0] if match
      flickr_id = flickr_id.gsub('#','')
    # end
    return flickr_id
  end

  # ====================
  # = Instance methods =
  # ====================

  def flickr_api
    @flickr_api ||= Flickr.new(FLICKR.merge(:token => flickr_token))
  end

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
    return if custom_client_hash == custom_client_hash_str # don't change the hash if it is the same as current
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
    "https://flickr4twitter.com/clients/tweetie/#{url_client_hash}.xml" 
  end  
  
  def avatar_url(size='n')
    # size options: {
    #   :m => '24x24',
    #   :n => '48x48',
    #   :b => '73x73',
    #   :o => 'original'
    # }
    "http://img.tweetimag.es/i/#{twitter_username}_#{size}"
  end
  
  def flickr_deauth_url
    token = flickr_token.split('-').first if flickr_token
    deauth_url = "http://flickr.com/services/auth/list.gne?from=extend" if token.blank?
    deauth_url ||= "http://www.flickr.com/services/auth/revoke.gne?token=#{token}" 
    deauth_url
  end

  def twitter_deauth_url
    "http://twitter.com/account/connections"
  end

end
