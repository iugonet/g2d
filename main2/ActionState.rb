# -*- coding : utf-8 -*-

require 'fileutils'

class ActionState

 Change_log = "Change.log"


 def initialize( pwd )
   @pwd = pwd
   @changeList = Array.new

   f = pwd + "/" + Change_log
   fr = open( f, "r" )
   fr.each { |line|
     @changeList << (line.chomp).strip
   }
   fr.close

   @addList     = Array.new
   @replaceList = Array.new
   @deleteList  = Array.new
 end
 
 def sift
   for i in 0..@changeList.size-1
     fl = @changeList[i].split(":")
     fa = (fl[1].strip).split(",")
     if fa.size == 0
       puts "Error: program bug."
     elsif fa.size == 1
       fas = fa[0]
       if fas == "add"
         @addList << fl[0].strip
       elsif fas == "replace"
         @replaceList << fl[0].strip
       elsif fas == "delete"
         @deleteList << fl[0].strip
       end
     else
       fas = fa[0]
       fae = fa[fa.size-1]
       if fae == "add"
         if fas == "add"
           @addList << fl[0].strip
         else
           @replaceList << fl[0].strip
         end
       elsif fae == "replace"
         if fas == "add"
           @addList << fl[0].strip
         else
           @replaceList << fl[0].strip
         end
       elsif fae == "delete"
         if fas == "add"
         else
           @deleteList << fl[0].strip
         end
       end
     end
   end
 end

 def getAddList
   return @addList
 end
 def getReplaceList
   return @replaceList
 end
 def getDeleteList
   return @deleteList
 end

 def test
  puts "add: "
  for i in 0..@addList.size-1
    puts @addList[i]
  end
  puts "replace: "
  for i in 0..@replaceList.size-1
    puts @replaceList[i]
  end
  puts "delete: "
  for i in 0..@deleteList.size-1
    puts @deleteList[i]
  end
 end
end
