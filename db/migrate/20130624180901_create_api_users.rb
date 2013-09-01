class CreateApiUsers < ActiveRecord::Migration
  def change
    create_table :api_users do |t|
	  
	  t.string "first_name"
	  t.string "last_name"
	  t.string "email"
	  t.string "api_key"
      t.timestamps
	  
    end
	
  end
end
