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

 def writeStruct( baseDir, nameList, handleList, typeList )
   addList = Array.new
   dstr = baseDir
   for i in 0..nameList.size-1
     dstr = dstr + nameList[i]
     str = dstr + " " + handleList[i] + " " + typeList[i]
     addList << str
     dstr = dstr + "/"
   end
   @gSpace.writeStruct( addList )
 end

 def setStruct
   @stDirList = Array.new
   @stHandleList = Array.new
   @stTypeList = Array.new
   for i in 0..@stList.size-1
     la = @stList[i].split(" ")
     if la.length == 3
       @stDirList    << la[0].strip
       @stHandleList << la[1].strip
       @stTypeList   << la[2].strip
     else
       puts "Error"
       exit
     end
   end
 end

 def setFileList( fileList )
   @dirList = getDirList( fileList )
   @newList = getNewList
 end

 def getDirList( addList )
   dirList = Array.new
   for i in 0..addList.size-1
     dirList << File.dirname( addList[i].getRelative )
   end
   dirList.uniq!
   dirList.sort!
   return dirList
 end

 def getNewList()
   newList = Array.new
   for i in 0..@dirList.size-1
     newadd = true
     for j in 0..@stDirList.size-1
       if @dirList[i] == @stDirList[j]
         newadd = false
         break
       end
     end
     if newadd
       newList << @dirList[i]
     end
   end
   return newList
 end

 def build

   for i in 0..@newList.size-1
     la = @newList[i].split("/")

     depth, handleID = getTopDir( la )
     if handleID == ""
       handleID = "null"
     end
     baseDir = getBaseDir( la, depth )

     fni = sprintf( IN_filename, i )
     fno = sprintf( OUT_filename, i )
     type = writeInputFile( fni, depth, la )
     cstr = @ds.getStructureBuilderCommand( fni, fno, handleID, type )
     system( cstr )

     nameList = Array.new
     handleList = Array.new
     typeList = Array.new
     readLog( fno, nameList, handleList, typeList )
     writeStruct( baseDir, nameList, handleList, typeList )

     readStruct()
     setStruct()
   end
 end

 def getTopDir( dl )
   depth = -1
   handleID = ""
   tdir = ""
   for j in 0..dl.size-1
     tdir = tdir + dl[j]
     for k in 0..@stDirList.size-1
       if tdir == @stDirList[k]
         depth = j
         handleID = @stHandleList[k]
         break
       end
     end
     tdir = tdir + "/"
   end
   return depth, handleID
 end

 def getBaseDir( dl, depth )
   basedir = ""
   for i in 0..depth
     basedir = basedir + dl[i] + "/"
   end
   return basedir
 end

 def writeInputFile( filename, depth, dl )
   type = "collection"
   fw = writeInit( filename )
   for i in depth+1..dl.size-2
     writeCommunity( fw, dl[i], dl[i] )
     type = "community"
   end
   writeCollection( fw, dl[dl.size-1], dl[dl.size-1] )
   for i in depth+1..dl.size-2
     writeCommunityEnd( fw )
   end
   writeFinalize( fw )
   return type
 end

 def readLog( fno, nameList, handleList, typeList )
   fr = open( fno, "r" )
   doc = REXML::Document.new fr
   doc.elements.each("imported_structure"){|is|
     scanID( is, nameList, handleList, typeList )
   }
   fr.close
 end

 def scanID( elem, nameList, handleList, typeList )
   elem.elements.each("collection"){|col|
     typeList << "col"
     getID( col, nameList, handleList )
   }
   elem.elements.each("community"){|com|
     typeList << "com"
     getID( com, nameList, handleList )
     scanID( com, nameList, handleList, typeList )
   }
 end

 def getID( element, nameList, handleList )
   nameList   << element.get_text("name").to_s
   handleList << element.attribute("identifier").to_s
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
