class ApiController < ApplicationController
	
 def authenticate key
	if ApiUser.find_by_api_key(key)
		return true
	else 
		return false
	end
 end

 def auto
 	@id =params[:id] || ""
	#Returns a list of drugs matching params[:id]
	if !@id.empty?# Authenticating and validating key and id
		@drugs = Drug.find(:all,:conditions => ['brand LIKE ?', "%#{params[:id]}%"], :limit =>(@limit= params[:limit] || 50 ))
		@brands=Array.new
		
		@drugs.each do |d|
			@brands.push(d.brand)
		end
		
		respond_to do |format|
		  format.html { render json:@brands.to_json }
		  format.json { render json:@brands.to_json }
		  format.xml { render xml: @brands.to_xml(:root => 'suggestions') }
		end
	else
		
		@brands=Array.new
		respond_to do |format|
		  format.html { render json:@brands.to_json }
		  format.json { render json:@brands.to_json }
		  format.xml { render xml: @brands.to_xml(:root => "#{@msg}") }
		end
	end
	
 end

 def suggest 
 	@id =params[:id] || ""
 	@key=params[:key] || ""
	#Returns a list of drugs matching params[:id]
	if !@id.empty? && !@key.empty? && authenticate("#{@key}")# Authenticating and validating key and id
		@drugs = Drug.find(:all,:conditions => ['brand LIKE ?', "%#{params[:id]}%"], :limit =>(@limit= params[:limit] || 100 ))
		@brands=Array.new
		@i=0
		@drugs.each do |d|
			@temp={"suggestion" => "#{d.brand}"}
			@brands.push(@temp)
			@i=@i+1
		end
		
		respond_to do |format|
		  format.html { render json: "\{\"suggestions\" :"+@brands.to_json+"\}" }
		  format.json { render json: "\{\"suggestions\" :"+@brands.to_json+"\}" }
		  format.xml { render xml: @brands.to_xml(:root => 'suggestions') }
		end
	else
		if !authenticate("#{params[:key]}")
			@msg="authentication failed"
		else
			@msg="empty parameters"
		end
		@brands=Array.new
		respond_to do |format|
		  format.html { render json: "\{\"#{@msg}\" :"+@brands.to_json+"\}" }
		  format.json { render json: "\{\"#{@msg}\" :"+@brands.to_json+"\}" }
		  format.xml { render xml: @brands.to_xml(:root => "#{@msg}") }
		end
	end
	
 end
 
 def search
 	@id =params[:id] || ""
 	@key=params[:key] || ""
	#Returns a list of drugs matching params[:id]
	if !@id.empty? && !@key.empty? && authenticate("#{@key}")# Authenticating and validating key and id
 			@drugs = Drug.find(:all,:conditions => ['brand LIKE ?', "#{params[:id]}"])
			#If array has one element
			if @drugs.length==1
				
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
				@alt_temp=Generic.where(name: @generics_name_array, qty: @drug_constituents.first.qty, strength: @generics_strength_array )
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
				@uniq_gen_ids=@generics_id_array.uniq
				
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
				if params[:type]=="adv"#Advanced Search
					
				else#Normal Search 
					@alt_drugs.each do |dd|
						if (@drugs.first.category== dd.category) ||((@drugs.first.category=="Vial"||@drugs.first.category=="Amp"||@drugs.first.category=="Dose")&&(dd.category=="Vial"||dd.category=="Amp"||dd.category=="Dose"))|| ((@drugs.first.category=="Tablet" || @drugs.first.category=="Capsule" || @drugs.first.category=="Kit" || @drugs.first.category=="Rotacap") && (dd.category=="Tablet" || dd.category=="Capsule" || dd.category=="Kit" ||dd.category=="Rotacap"))
							@temp.push(dd)
						end
					end
					@alt_drugs=@temp
				end

				if  !params[:limit].blank?
					if params[:limit].to_i>=@alt_drugs.length
					@limit=@alt_drugs.length
					else
					@limit=params[:limit].to_i
					end
				else
					@limit=@alt_drugs.length
				end
				
				respond_to do |format|
				  format.html { render json: "\{\"drugs\" :"+@alt_drugs[0,@limit].to_json+"\}" }
				  format.json { render json: "\{\"drugs\" :"+@alt_drugs[0,@limit].to_json+"\}" }
				  format.xml { render xml: @alt_drugs[0,@limit].to_xml(:root => "drugs") }
				end
			
			elsif @drugs.length==0
				@alt_drugs=[]
				respond_to do |format|
				  format.html { render json: "\{\"drugs\" :"+@alt_drugs[0,(@limit= params[:limit].to_i || 5000)].to_json+"\}" }
				  format.json { render json: "\{\"drugs\" :"+@alt_drugs[0,(@limit= params[:limit].to_i || 5000)].to_json+"\}" }
				  format.xml { render xml: @alt_drugs[0,(@limit= params[:limit].to_i || 5000)].to_xml(:root => "drugs") }
				end
			else
				@alt_drugs=[]
				respond_to do |format|
				  format.html { render json: "\{\"drugs\" :"+@alt_drugs[0,(@limit= params[:limit].to_i || 5000)].to_json+"\}" }
				  format.json { render json: "\{\"drugs\" :"+@alt_drugs[0,(@limit= params[:limit].to_i || 5000)].to_json+"\}" }
				  format.xml { render xml: @alt_drugs[0,(@limit= params[:limit].to_i || 5000)].to_xml(:root => "drugs") }
				end

		    end
		    	
	else
		if !authenticate("#{params[:key]}")
			@msg="authentication failed"
		else
			@msg="empty parameters"
		end
		@brands=Array.new
		respond_to do |format|
		  format.json { render json: "\{\"#{@msg}\" :"+@brands.to_json+"\}" }
		  format.json { render json: "\{\"#{@msg}\" :"+@brands.to_json+"\}" }
		  format.xml { render xml: @brands.to_xml(:root => "#{@msg}") }
		end
	end

end
 def medicine 
 	@id =params[:id] || ""
 	@key=params[:key] || ""
	#Returns a list of drugs matching params[:id]
	if !@id.empty? && !@key.empty? && authenticate("#{@key}")# Authenticating and validating key and id
		@drug = Drug.find(:all,:conditions => ['brand LIKE ?', "#{params[:id]}"])
		
		
		respond_to do |format|
		  format.html { render json: "\{\"medicine\" :"+@drug.to_json+"\}"}
		  format.json { render json: "\{\"medicine\" :"+@drug.to_json+"\}" }
		  format.xml { render xml: @drug.to_xml(:root => 'medicine') }
		end
	else
		if !authenticate("#{params[:key]}")
			@msg="authentication failed"
		else
			@msg="empty parameters"
		end
		@brands=Array.new
		respond_to do |format|
		  format.html { render json: "\{\"#{@msg}\" :"+@brands.to_json+"\}" }
		  format.json { render json: "\{\"#{@msg}\" :"+@brands.to_json+"\}" }
		  format.xml { render xml: @brands.to_xml(:root => "#{@msg}") }
		end
	end
	
 end

def typeahead 
 	@id =params[:id] || ""
 	@key=params[:key] || ""
	#Returns a list of drugs matching params[:id]
	if !@id.empty? && !@key.empty? && authenticate("#{@key}")# Authenticating and validating key and id
		@drugs = Drug.find(:all,:conditions => ['brand LIKE ?', "%#{params[:id]}%"], :limit =>(@limit= params[:limit] || 100 ))
		@brands=Array.new
		@i=0
		@drugs.each do |d|
			@temp=d.brand
			@brands.push(@temp)
			@i=@i+1
		end
		
		respond_to do |format|
		  format.html { render json: @brands.to_json }
		  format.json { render json: @brands.to_json }
		  format.xml { render xml: @brands.to_xml(:root => 'suggestions') }
		end
	else
		if !authenticate("#{params[:key]}")
			@msg="authentication failed"
		else
			@msg="empty parameters"
		end
		@brands=Array.new
		respond_to do |format|
		  format.html { render json: "\{\"#{@msg}\" :"+@brands.to_json+"\}" }
		  format.json { render json: "\{\"#{@msg}\" :"+@brands.to_json+"\}" }
		  format.xml { render xml: @brands.to_xml(:root => "#{@msg}") }
		end
	end
	
 end

 
end
