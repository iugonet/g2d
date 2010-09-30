class HandleIDList

 def initialize( filename )
   @filename = filename
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

 def add( list )
    @list.concat( list )
   @list.uniq!
 end

 def write
   fw = open( @filename, "w" )
   for i in 0..@list.size-1
      fw.puts @list[i]
   end
   fw.close
 end

 def checkOverlap
   for i in 0..@list.size-2
     ih = @list[i].split(" ")
     for j in i+1..@list.size-1
       jh = @list[j].split(" ")
       if ih[0] == jh[0] || ih[1] == jh[1]
         puts "Error: handle list: " + @filename
         puts ih[0] + " : " + jh[0]
         puts ih[1] + " : " + jh[1]
         exit
       end
     end
   end
 end

 def deleteFile( filename )
   ii = -1
   for i in 0..@list.size-1
     ih = @list[i].split(" ")
     if ih[0] == filename
       ii = i
       break
     end
   end
   if ii != -1
     delete( ii )
   else
     puts "Delete error: " + filename
     exit
   end
 end

 def deleteID( id )
   ii = -1
   for i in 0..@list.size-1
     ih = @list[i].split(" ")
     if ih[1] == id
       ii = i
       break
     end
   end
   if ii != -1
     delete( ii )
   else
     puts "Delete error: " + id
     exit
   end
 end

 def delete( i )
   ih = @list[i].split(" ")
   filename = ih[0]
   id = ih[1]
   @list.delete_at(i)
   puts "Delete: " + filename + " : " + id
 end

end
