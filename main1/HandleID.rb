class HandleID

 def initialize( filename )
    @filename = filename
 end

 def read
   @list = getLineList()
 end

 def getLineList
   lineList = Array.new
   fr = open( @filename, "r" )
   fr.each { |line|
     lineList << (line.chomp).strip
   }
   fr.close
   return lineList
 end

 def getID( file )
   iid = nil
   did = nil
   for i in 0..@list.size-1
     il = @list[i].split(" ")
     if il[0] == file
       iid = il[1]
       did = i
       break
     end
   end
   return iid, did
 end

 def delete( dlist )
   dlist.sort!
   dlist.reverse!
   for i in 0..dlist.size-1
      id = dlist[i]
      @list.delete_at(id)
   end
 end

 def write
   fw = open( @filename, "w" )
   for i in 0..@list.size-1
     fw.puts @list[i]
   end
   fw.close
 end

end
