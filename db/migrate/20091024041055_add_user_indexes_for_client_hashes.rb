class AddUserIndexesForClientHashes < ActiveRecord::Migration
  def self.up
    add_index :users, :client_hash
    add_index :users, :custom_client_hash
  end

  def self.down
    remove_index :users, :custom_client_hash
    remove_index :users, :client_hash
  end
end
