
def check_for_subject_syntax(cnf,subject)
  action = nil
  obj = nil
  subject_tokens =	subject.to_s.split(" ").collect{|str|  str.downcase unless str.strip.blank?}

  cnf["Object"].each{|key,val|
     subj_arr = val["subject"].split(",")
     action_index = subj_arr.index("action")
     obj_index = subj_arr.index(key)
  
      if ["create","update"].include?(subject_tokens[action_index]) and key.downcase == subject_tokens[obj_index]
       action = subject_tokens[action_index]
       obj = subject_tokens[obj_index]
       break
     end   
  }
  return action,obj
end


def call_object_action(cnf,obj,action,body)
  p "Body"
  p body
  attr_hash = {}
  begin
   delimiter = cnf["Object"][obj]["delimiter"]
  
   body.split(delimiter).each{|key_val|
     next if key_val.strip.blank?
     fval =key_val.split(":")
     next if fval[0].blank?
     key,val = get_field_vals(cnf["Object"][obj]["fields"],fval[0],fval[1])
     raise "Fields are not matched" if key.nil? 
     attr_hash[key] = val
    
   }


   camel_obj = obj.camelcase
  p "Creating #{camel_obj}.create(#{attr_hash})"
	  eval "#{camel_obj}.create(#{attr_hash})"  if action == "create"
    eval "#{camel_obj}.update_attributes(#{attr_hash})" if action == "update"
   rescue Exception => e
     p "Exception: "+e.to_s
   end
end	


def get_field_vals(fields,body_key,value)

  fields.each{|key,val|
    return body_key,value if val["label"].downcase == body_key.downcase
  }

  return nil, nil
end  