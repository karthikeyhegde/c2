module ApplicationHelper
  def space(n)
   str = ""
    for i in 1..n
      str << "&nbsp;"
    end
   return str.html_safe
  end


   def number_to_indian_currency(number) 
      if number 

      	string = number.to_s.split('.') 
        
        number = string[0].gsub(/(\d+)(\d{3})$/){

         p = $2;"#{$1.reverse.gsub(/(\d{2})/,'\1,').reverse},#{p}"} 
         number = number.gsub(/^,/, '') + '.' + string[1] if string[1]  if number[0] == 44 

       end 
        "Rs.#{number}" 
     end
end
