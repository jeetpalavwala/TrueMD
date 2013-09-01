class ApiUser < ActiveRecord::Base
   attr_protected :first_name, :last_name, :api_key
end
