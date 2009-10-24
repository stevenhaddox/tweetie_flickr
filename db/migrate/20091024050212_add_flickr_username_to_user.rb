class AddFlickrUsernameToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :flickr_username, :string
  end

  def self.down
    remove_column :users, :flickr_username
  end
end
