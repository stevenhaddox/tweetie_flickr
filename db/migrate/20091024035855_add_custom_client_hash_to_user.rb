class AddCustomClientHashToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :custom_client_hash, :string
  end

  def self.down
    remove_column :users, :custom_client_hash
  end
end
