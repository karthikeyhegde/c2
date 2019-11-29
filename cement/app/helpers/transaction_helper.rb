module TransactionHelper

	def array_text_field(object_name,field_name,style_str,value,row_number = nil)
	   str =	"<input type='text' class = 'input item_numbers' name='"+object_name+"["+row_number+"]["+field_name+"]' id='"+object_name+"_"+field_name+"_"+row_number+"'"
	   str += " size='10' style='"+style_str+"'" unless style_str.blank?
	   str += " value='"+ value+"' /> "
      return str.html_safe

	end	


	def array_select(object_name,field_name,style_str,option_values,row_number = nil)
		str =  	"<select  class = 'input item_val' name='"+object_name+"["+row_number.to_s+"]["+field_name+"]' id='"+object_name+"_"+field_name+"_"+row_number+"'"
	    str += " style='"+style_str+"'" unless style_str.nil?
	    str += ">"
	    str += " <option value =''></value>"
        str += option_values
        str += '</select>'

        return str.html_safe
	end	
end
