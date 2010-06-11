# -*- coding : utf-8 -*-

require 'find'
require 'fileutils'
require 'rexml/document'
include REXML


class StructCompact

 $h_file = "h.log"
 $out_filename = "st%05d.xml"

 def initialize( pwd )
   @pwd = pwd
   @hList = Array.new
   f = pwd + "/" + $h_file
   fr = open( f, "r" )
   fr.each { |line|
      @hList << (line.chomp).strip
   }
   fr.close

   @topList = Array.new
   @dirList = Array.new
   for i in 0..@hList.size-1
     ha = @hList[i].split(" : ")
     @topList << ha[0].strip
     @dirList << ha[1].strip
   end


   for i in 0..@hList.size-1
     puts @hList[i] + " " + @topList[i] + " " + @dirList[i]
   end
 end

 def test

  ii = 0
  while ( @hList.size > 0 )
    puts "start"
    puts @dirList[0]
    ha = @dirList[0].split("/")

    @hList.delete_at(0)
    @topList.delete_at(0)
    @dirList.delete_at(0)

    bdirList = Array.new
    for i in 0..@dirList.size-1
      bdirList << @dirList[i]
    end
    cList = Array.new
    for i in 0..bdirList.size-1
      cList << -1
    end
    for i in 0..ha.size-1
       for j in 0..bdirList.size-1
          haj = bdirList[j].split("/")
          if haj.size-1 > i
            if ha[i] == haj[i] && cList[j] == i-1
               cList[j] = i
            end
          end
       end
       for j in 0..bdirList.size-1
         if cList[j] < 0
             cList[j] = nil
             bdirList[j] = nil
         end
       end
       cList.compact!
       bdirList.compact!
    end

    for i in 0..bdirList.size-1
      puts bdirList[i]
    end

    dList = Array.new
    for i in 0..@dirList.size-1
       for j in 0..bdirList.size-1
          if @dirList[i] == bdirList[j]
            dList << i
          end
       end
    end
    for i in 0..dList.size-1
       id = dList[i]-i
       @hList.delete_at( id )
       @topList.delete_at( id )
       @dirList.delete_at( id )
    end

    for i in 0..cList.size-1
#      puts cList[i].to_s + " " + bdirList[i]
      puts cList[i]
    end

    file = sprintf( "cst%05d.xml", ii )
    fw = writeInit( file )
=begin
    for i in 0..ha.size-2
      while ( cList.size > 0 )
        if cList[0] == i
           
        end
      end
    end
    for i in 0..cList.size-1
      
    end
=end
    writeFinalize( fw )

    ii = ii + 1
  end

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
   fw.printf(" <name>%s</name>", name )
   fw.printf(" <description>%s</description>", description )
 end

 def writeCommunityEnd( fw )
   fw.puts "</community>"
 end

 def writeCollection( fw, name, description )
   fw.puts "<collection>"
   fw.printf(" <name>%s</name>", name )
   fw.printf(" <description>%s</description>", description )
   fw.puts "</collection>"
 end

end
