class CreateGenerics < ActiveRecord::Migration
  def change
    create_table :generics do |t|

      t.integer "generic_id"
	  t.integer "qty"
	  t.string "name"
	  t.string "strength"
    end
  end
end
