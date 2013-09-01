class AutocompleteController < ApplicationController
def index
end
def search
	#Returns a list of drugs matching params:id
	@drugs = Drug.find(:all,:conditions => ['brand LIKE ?', "%#{params[:id]}%"])
	@brands=Array.new
	@drugs.each do |d|
		@brands.push(d.brand)
	end
	render(:json =>"#{@brands.to_json}")
end

end
