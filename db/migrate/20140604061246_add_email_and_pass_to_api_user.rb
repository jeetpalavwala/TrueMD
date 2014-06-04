class AddEmailAndPassToApiUser < ActiveRecord::Migration
  def change
  	add_column :api_users, :password, :string
  end
end
