class ReportController < ApplicationController
  #Index Action
  def index
	#If someone just types http://wwww...../report/, he is redirected to the home page
	redirect_to(:controller => 'home',:action => 'index')
  end

  #Show Action  
  def show
	#Check whether it is normal or advanced search: 1-Normal Search, 2-Advanced Search
	@tag_ids = params[:search_tag] || params[:tag_ids]

	
	#Returns a list of drugs matching params:id
	
	#Checking Search Parameter to be empty
	if params[:id].blank?
			flash[:notice]="Sorry! can't be blank. Enter a medicine."
			redirect_to(:controller => 'home',:action => 'index')
	
	# If search parameter is not empty
	else
			@drugs = Drug.find(:all,:conditions => ['brand LIKE ?', "#{params[:id]}"])

			#If array has one element
			if @drugs.length==1

				#Cookie
				@cookies =[cookies[:r1],cookies[:r2],cookies[:r3],cookies[:r4],cookies[:r5]]
				hash = Hash[@cookies.map.with_index.to_a]
				hash["#{params[:id]}"]
				if !@cookies.include? ("#{params[:id]}")
				cookies[:r5]=cookies[:r4]
				cookies[:r4]=cookies[:r3]
				cookies[:r3]=cookies[:r2]
				cookies[:r2]=cookies[:r1]
				cookies[:r1]={ :value => "#{params[:id]}"}
				end

				#Extracting Constituents of the branded drug
				@drug_constituents= Generic.find(:all, :conditions =>{:generic_id => @drugs.first.generic_id})

				@generics_name_array= Array.new
				@generics_id_array= Array.new
				@generics_strength_array= Array.new
				@drug_constituents.each do |gen|
					@generics_name_array.push(gen.name)
					@generics_strength_array.push(gen.strength)
				end

				#Finding alternate branded drugs having above generic or strength... It still have few errors
				@alt_temp=Generic.where(name: @generics_name_array, qty: @drug_constituents.first.qty, strength:@generics_strength_array )
				@hash= Hash[@generics_name_array.zip @generics_strength_array]
				@alt=[]
				# Correcting the temporary alternate drug list,creating alt list
				@hash.each do |key,value|
					@temp=@alt_temp.select { |a| a.name==key && a.strength==value }
					@alt=@alt.concat(@temp)
				end

				#Grabbing all generic_ids of alt list
				@alt.each do |at|
					@generics_id_array.push(at.generic_id)
				end

				#Extracting unique generic_ids
				#@uniq_gen_ids=@generics_id_array.uniq ##not working in heroku
				@uniq_gen_ids=@generics_id_array

				#Final list of alternative medicines
				@final_alt=Array.new
				@uniq_gen_ids.each do |ids|
					@id_flag= true
					@t=@alt.select { |a| a.generic_id==ids}
					if @t.length== @drug_constituents.first.qty
					@hash.each do |key,value|
						@drug_flag==false
						@t.each do |tt|
							if	tt.name== key && tt.strength==value then
								@drug_flag==true
								break
							end

						end
						if @drug_flag==false then
							@id_flag= false
							break
						end

					end

					if @id_flag==true
						@final_alt.push(ids)
					end
					end


				end	# End Final List

				#List of drugs from generic_id
				@alt_drugs= Drug.where(generic_id: @final_alt)

				#Avoiding repetetions and ordering it
				@alt_drugs=@alt_drugs.uniq.order('package_price/package_qty ASC')
				@temp=Array.new
				if @tag_ids.include?("2")#Advanced Search
					@alt_drugs_paginated = @alt_drugs.page(params[:page])
					@found=@alt_drugs.length
				else#Normal Search 
					@alt_drugs.each do |dd|
						if (@drugs.first.category== dd.category) ||((@drugs.first.category=="Vial"||@drugs.first.category=="Amp"||@drugs.first.category=="Dose")&&(dd.category=="Vial"||dd.category=="Amp"||dd.category=="Dose"))|| ((@drugs.first.category=="Tablet" || @drugs.first.category=="Capsule" || @drugs.first.category=="Kit" || @drugs.first.category=="Rotacap") && (dd.category=="Tablet" || dd.category=="Capsule" || dd.category=="Kit" ||dd.category=="Rotacap"))
							@temp.push(dd)
						end
					end
					@found=@temp.length
					@alt_drugs_paginated=Kaminari.paginate_array(@temp).page(params[:page])
				end

			render('report/show')
			#render(:json => "#{@temp.class}")



			#If no matching drugs found	or #If more than one drug found
			else @drugs.length==0
				@suggestions = Drug.find(:all,:conditions => ['brand LIKE ?', "%#{params[:id]}%"])
				@suggestions_paginated=Kaminari.paginate_array(@suggestions).page(params[:page])
				if @suggestions.blank?
					render('report/not_found')
				else
					render('report/found')
				end
			end
	end# end of empty check block
	#render('report/show')
  end # End of show action
  
end
