class RemoveTwitterPasswordFromUser < ActiveRecord::Migration
  def self.up
    remove_index :users, :twitter_password
    remove_column :users, :twitter_password
  end

  def self.down
    add_column  :users, :twitter_password, :string
    add_index :users, :twitter_password
  end
end
