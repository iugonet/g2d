# -*- coding : utf-8 -*-

require 'find'
require 'fileutils'

class StructureBuilder

 $exc          = "/home/odc/kouno/iugonet_git/WorkingDir/Metadata_Draft"
 $log_dir      = "/gitlog/test_import"
 $log_filename = "structure"
 $out_filename = "st%05d.xml"

 def initialize( pwd )
  @pwd = pwd

  @stList = Array.new
  f = pwd + $log_dir + "/" + $log_filename
  if FileTest.exist?( f )
    fr = open( f, "r" )
    fr.each { |line|
      @stList << (line.chomp).strip
    }
  else
    fw = open( f, "w" )
    fw.close
  end

  @stDirList    = Array.new
  @stHandleList = Array.new
  for i in 0..@stList.size-1
    la = @stList[i].split(" ")
    if la.length == 2
      @stDirList    << la[0].strip
      @stHandleList << la[1].strip
    else
      puts "Error"
      exit
    end
  end

 end

 def setFileList( addList )
   @addList = addList
   @dirList = Array.new

   for i in 0..@addList.size-1
      dir = File.dirname( @addList[i] )
      len = $exc.length
      dir.slice!(0,len+1)
      @dirList << dir
   end

   @dirList.uniq!
   @dirList.sort!

   @newList = Array.new
   @hnewList = Array.new
   for i in 0..@dirList.size-1
      adding = true
      for j in 0..@stDirList.size-1
         if @dirList[i] == @stDirList[j]
            adding = false
            break
         end
      end
      if adding
         @newList << @dirList[i]
         @hnewList << @dirList[i]
      end
   end
 end

 def test

   hList = Array.new

   ii = 0
   while ( @newList.size > 0 )
     la = @newList[0].split("/")
     jj = -1
     ha = ""
     d = ""
     for j in 0..la.size-1
       d = d + "/" + la[j]
       for k in 0..@stDirList.size-1
          if d == @stDirList.size-1
             jj = j
             ha = @stDirList[k]
             break
          end
       end
     end
     @newList.delete_at(0)

     hList << ha
     fn = sprintf( $out_filename, ii )
     fw = writeInit( fn )
     for k in jj+1..la.size-2
        writeCommunity( fw, la[k], la[k] )
     end
     writeCollection( fw, la[la.size-1], la[la.size-1] )
     for k in jj+1..la.size-2
        writeCommunityEnd( fw )
     end
     writeFinalize( fw )

     ii = ii + 1
   end

   fw = open( "h.log", "w" )
   for i in 0..hList.size-1
      if hList[i].length != 0
          fw.puts hList[i] + " : " + @hnewList[i]
      else
          fw.puts "null" + " : " + @hnewList[i]
      end
   end
   fw.close

 end

 def writeInit( filename )
  fw = open( filename, "w" )
  fw.puts "<import_structure>"
  return fw
 end

 def writeFinalize( fw )
  fw.puts "</import_structure>"
  fw.close
 end

 def writeCommunity( fw, name, description )
   fw.puts "<community>"
   fw.printf(" <name>%s</name>\n", name )
   fw.printf(" <description>%s</description>\n", description )
 end

 def writeCommunityEnd( fw )
   fw.puts "</community>"
 end

 def writeCollection( fw, name, description )
   fw.puts "<collection>"
   fw.printf(" <name>%s</name>\n", name )
   fw.printf(" <description>%s</description>\n", description )
   fw.puts "</collection>"
 end

end
