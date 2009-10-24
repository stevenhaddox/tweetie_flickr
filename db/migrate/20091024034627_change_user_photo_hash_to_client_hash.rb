class ChangeUserPhotoHashToClientHash < ActiveRecord::Migration
  def self.up
    rename_column(:users, :photo_hash, :client_hash)
  end

  def self.down
    rename_column(:users, :client_hash, :photo_hash)
  end
end
