# -*- coding : utf-8 -*-
require 'find'
require 'fileutils'
require 'rexml/document'
include REXML

require 'main2/DSpace'

class StructBuilder

 IN_filename  = "ist%05d.xml"
 OUT_filename = "ost%05d.xml"

 def initialize( pwd, workDir, gSpace )
  @pwd = pwd
  @workDir = workDir
  @gSpace = gSpace

  @ds = DSpace.new( @pwd )

  readStruct()
  setStruct()
 end

 def readStruct()
   @stList = @gSpace.readStruct()
 end

 def writeStruct( base, nameList, handleList )
   addList = Array.new
   dstr = base
   for i in 0..nameList.size-1
     dstr = dstr + nameList[i]
     str = dstr + " " + handleList[i]
     addList << str
     dstr = dstr + "/"
   end
   @gSpace.writeStruct( addList )
 end

 def setStruct
  @stDirList = Array.new
  @stHandleList = Array.new
  for i in 0..@stList.size-1
    la = @stList[i].split(" ")
    if la.length == 2
      @stDirList << la[0].strip
      @stHandleList << la[1].strip
    else
      puts "Error"
      exit
    end
  end
 end

 def setRepoDirList( repoDirList )
   @repoDirList = repoDirList
 end
 def setTopList( topList )
   @topList = topList
 end

 def setFileList( addList )
   @addList = addList
   @dirList = Array.new


   for i in 0..@addList.size-1
     dir = File.dirname( @addList[i] )

     for j in 0..@repoDirList.size-1
       r = File.dirname(@repoDirList[j])
       rd = r.gsub(/[\/]/,'_')
       rdir = @pwd + "/" + @workDir + "/" + rd + "/" + File.basename( @repoDirList[j], ".git" )
       if dir.include?( rdir )
         dir.slice!(0,rdir.length+1)
         if @topList[j] != nil &&
            @topList[j] != ""
           dir = @topList[j] + "/" + dir
           break
         end
       end
     end
     @dirList << dir
   end
   @dirList.uniq!
   @dirList.sort!

   @newList = Array.new
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
      end
   end

 end

 def build

  for i in 0..@newList.size-1
    la = @newList[i].split("/")
    jj = -1
    ha = ""
    d = ""
    for j in 0..la.size-1
       d = d + la[j]
       for k in 0..@stDirList.size-1
          if d == @stDirList[k]
             jj = j
             ha = @stHandleList[k]
             break
          end
       end
       d = d + "/"
    end

    base = ""
    for j in 0..jj
      base = base + la[j]
      base = base + "/"
    end
    type = "collection"
    fni = sprintf( IN_filename, i )
    fno = sprintf( OUT_filename, i )
    fw = writeInit( fni )
    for k in jj+1..la.size-2
      writeCommunity( fw, la[k], la[k] )
      type = "community"
    end
    writeCollection( fw, la[la.size-1], la[la.size-1] )
    for k in jj+1..la.size-2
       writeCommunityEnd( fw )
    end
    writeFinalize( fw )

    if ha == ""
       ha = "null"
    end

    cstr = @ds.getStructureBuilderCommand( fni, fno, ha, type )
    system( cstr )

    nameList = Array.new
    handleList = Array.new
    readLog( fno, nameList, handleList )
    writeStruct( base, nameList, handleList )

    readStruct()
    setStruct()
  end

 end

 def readLog( fno, nameList, handleList )
   fr = open( fno, "r" )
   doc = REXML::Document.new fr
   doc.elements.each("imported_structure"){|is|
     scanID( is, nameList, handleList )
   }
   fr.close
 end

 def scanID( elem, nameList, handleList )
   elem.elements.each("collection"){|col|
     nameList   << col.get_text("name").to_s
     handleList << col.attribute("identifier").to_s
   }
   elem.elements.each("community"){|com|
     nameList   << com.get_text("name").to_s
     handleList << com.attribute("identifier").to_s
     scanID( com, nameList, handleList )
   }
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
   fw.puts   "<community>"
   fw.printf(" <name>%s</name>\n", name )
   fw.printf(" <description>%s</description>\n", description )
 end

 def writeCommunityEnd( fw )
    fw.puts "</community>"
 end

 def writeCollection( fw, name, description )
    fw.puts   "<collection>"
    fw.printf(" <name>%s</name>\n", name )
    fw.printf(" <description>%s</description>\n", description )
    fw.puts   "</collection>"
 end

end
