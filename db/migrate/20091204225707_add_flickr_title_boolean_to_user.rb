class AddFlickrTitleBooleanToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :flickr_title, :boolean
  end

  def self.down
    remove_column :users, :flickr_title
  end
end
