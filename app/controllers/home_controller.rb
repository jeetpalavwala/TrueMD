class HomeController < ApplicationController
  
  #caches_action :index
  def index
  #Returns a list of drugs matching params:id
	#@drugs = Drug.find(:all,:conditions => ['brand LIKE ?', "%#{params[:id]}%"])
	#@brands=Array.new
	
	#@drugs.each do |d|
	#	@brands.push(d.brand)
	#end
	
	render('home/search')
  end
  
end
