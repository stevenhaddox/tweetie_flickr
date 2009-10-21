class AddTwitterPinToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :twitter_pin, :string
    add_column :users, :twitter_rtoken, :string
    add_column :users, :twitter_rsecret, :string
  end

  def self.down
    remove_column :users, :twitter_pin
    remove_column :users, :twitter_rtoken
    remove_column :users, :twitter_rsecret
  end
end
