# -*- coding : utf-8 -*-

require 'fileutils'

class FileStatus

 Change_log   = "Change.log"
 FileStatus_log = "FileStatus.log"

 def initialize( pwd )
   @pwd = pwd
 end

 def readChangeLog
   @changeList = Array.new
   filename = @pwd + "/" + Change_log
   fr = open( filename, "r" )
   fr.each { |line|
     @changeList << (line.chomp).strip
   }
   fr.close
 end
 
 def split
   @addList     = Array.new
   @replaceList = Array.new
   @deleteList  = Array.new
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

 def writeLog
  fw = open( FileStatus_log, "w" )
  if @addList.size > 0
    fw.puts "add: "
    putsList( fw, @addList )
  end
  if @replaceList.size > 0
    fw.puts "replace: "
    putsList( fw, @replaceList )
  end
  if @deleteList.size > 0
    fw.puts "delete: "
    putsList( fw, @deleteList )
  end
  fw.close
 end
 def putsList( fw, list )
   for i in 0..list.size-1
     fw.puts list[i]
   end
 end
end
