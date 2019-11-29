class Locker

	@@Locker = {}

    def self.add_lock clsname
    	@@Locker[clsname] = []
    end	

    def release_lock clsname,id
    	@@Loker[clsname].delete(id)
    end
    
    def set_lock clsname, id
    	@@Locker[classname] = [] if !@@Loker.keys.include?(clsname)
    	while(1)
    	 if @@Loker[clsname].include?(id)
    	   sleep(1)
    	 else
    	 	@@Loker[clsname] << id
    	 	break
    	 end  
    	end 

    end	

end	