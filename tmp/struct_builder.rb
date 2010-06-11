# -*- coding : utf-8 -*-

require 'find'
require 'fileutils'
require 'rexml/document'
include REXML

class StructBuilder

 $exc      = "/home/odc/kouno/iugonet_git/WorkingDir/Metadata_Draft"
 $log_file = "/home/odc/kouno/iugonet_git/gitlog/test_import"
 $log_filename = "structure"

 def initialize( pwd )
   @pwd = pwd

   @stList = Array.new
   f = $log_file + "/" + $log_filename
   if FileTest.exist?( f )
     fr = open( f, "r" )
     fr.each { |line|
       @stList << (line.chomp).strip
     }
     fr.close
   else
     fr = open( f, "w" )
     fr.close
   end

   @stDirList    = Array.new
   @stHandleList = Array.new
   for i in 0..@stList.size-1
   end


 end


 def setFileList( addList )
   @addList = addList
 end

 def test
   @dirList = Array.new
   for i in 0..@addList.size-1
      dir = File.dirname( @addList[i] )
      len = $exc.length
      dir.slice!(0,len+1)
      @dirList << dir
   end
   @dirList.uniq!
   @dirList.sort!
   for i in 0..@dirList.size-1
     puts @dirList[i]
   end
 end

 def write
   fw = open( "st.xml", "w" )
   fw.puts "<import_structure>"
   for i in 0..@dirList.size-1
      puts @dirList[i]
      dl = @dirList[i].split("/")

      for j in 0..dl.size-2
         
      end

   end
   fw.puts "</import_structure>"
   fw.close
 end

 def initCommunity
   @endComm = 0
 end

 def writeCommunity( fw, name, description )
   fw.puts "<community>"
   fw.printf( "<name>%s</name>", name )
   fw.printf( "<description>%s</description>", description )
   @ednComm += 1
 end

 def finalizeCommunity
   fw.puts "</community>"
 end

 def writeCollection( fw, name, description )
   fw.puts "<collection>"
   fw.printf( "<name>%s</name>", name )
   fw.printf( "<description>%s</description>", description )
   fw.puts "</collection>"
 end

end
