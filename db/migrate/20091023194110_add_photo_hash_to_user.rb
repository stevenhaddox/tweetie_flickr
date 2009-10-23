class AddPhotoHashToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :photo_hash, :string
  end

  def self.down
    remove_column :users, :photo_hash
  end
end
