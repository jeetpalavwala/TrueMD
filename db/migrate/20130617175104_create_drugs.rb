class CreateDrugs < ActiveRecord::Migration
  def change
    create_table :drugs do |t|
	  
	  t.string "manufacturer"
	  t.string "brand"
	  t.string "category"
	  t.string "d_class"
	  t.float "unit_qty"
	  t.string "unit_type"
	  t.float "package_qty"
	  t.string "package_type"
	  t.float "package_price"
	  t.float "unit_price"
	  t.integer "generic_id"
	  
    end
  end
end
