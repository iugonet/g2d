# -*- coding : utf-8 -*-
require 'fileutils'
require 'tempfile'

require 'main2/FileList'
require 'main2/Spase2DSpace'
require 'main2/DSpace'
require 'util/ScriptMaker'

class ItemImport

 TempBase    = "ImportData_"
 TempBaseAll = "ImportData_*"
 Runfile = "runImport.sh"

 def initialize( pwd, workDir, gSpace )
   @pwd = pwd
   @workDir = workDir
   @gSpace = gSpace

   @ds = DSpace.new( @pwd )

   @stList = @gSpace.readStruct()

   @stHash = Hash.new
   for i in 0..@stList.size-1
     la = @stList[i].split(" ")
     if la.length == 3
        @stHash[ la[0].strip ] = la[1].strip
     end
   end
 end

 def setFileList( fileList )
   @fileList = fileList
 end

 def make()
   frf = @pwd + "/" + Runfile
   sm = ScriptMaker.new( frf )

   s2d = Spase2DSpace.new( @pwd )
   s2d.checkLength
   s2d.getQueryList

   while ( @fileList.size > 0  )
     tempDir = getTempDir
     Dir.mkdir( tempDir )
     logfile = tempDir + "/impfile"

     dir = File.dirname( @fileList[0].getRelative )
     handleID = @stHash[ dir ]

     addList, delIndexList = getAddList( dir )
     deleteList( delIndexList )

     itemIndex = 0
     for i in 0..addList.size-1
       if i%30000 == 29999
          mapfile = tempDir + "/mapfile"
          cstr = @ds.getImportCommand( handleID, tempDir, mapfile )
          sm.puts( cstr )
          tempDir = getTempDir
          Dir.mkdir( tempDir )
          logfile = tempDir + "/impfile"
          itemIndex = 0
       end
       itemIndex = itemIndex + 1
       afile = addList[i].getAbsolute
       rfile = addList[i].getRelative
       itemDir = tempDir + "/" + itemIndex.to_s
       Dir.mkdir( itemDir )
       FileUtils.install( afile, itemDir, :mode=>0664 )
       makeContentsFile( itemDir, afile )
       s2d.conv( afile, itemDir )
       writeImportLog( logfile, itemIndex, rfile )
     end

     mapfile = tempDir + "/mapfile"
     cstr = @ds.getImportCommand( handleID, tempDir, mapfile )
     sm.puts( cstr )
   end

   sm.finalize
   Dir.chdir( @pwd )
 end

 def getTempDir()
    tempFile = Tempfile.new( TempBase, @pwd )
    tdir = tempFile.path
    tempFile.close( true )
    return tdir
 end

 def getAddList( addDir )
   addList = Array.new
   delIndexList = Array.new
   for i in 0..@fileList.size-1
     file = @fileList[i].getRelative
     dir = File.dirname( file )
     if dir == addDir
       addList << @fileList[i]
       delIndexList << i
     end
   end
   return addList, delIndexList
 end

 def deleteList( delIndexList )
   for i in 0..delIndexList.size-1
     ri = delIndexList.size-1-i
     di = delIndexList[ri]
     @fileList.delete_at( di )
   end
 end

 def makeContentsFile( mdir, file )
   cfile = mdir + "/" + "contents"
   fwc = open( cfile, "w" )
   fwc.puts File.basename( file )
   fwc.close
 end

 def writeImportLog( logfile, i, file )
   fw = open( logfile, "a" )
   fw.printf( "%d %s\n", i, file )
   fw.close
 end

 def run
   Dir.chdir( @pwd )
   File.chmod( 0755, Runfile )
   com = sprintf( "./%s", Runfile )
   system( com )
 end

 def setMapfile
   newList = Array.new
   Dir.glob(TempBaseAll).each{ |name|
     pl = Array.new
     mapfile = name + "/mapfile"
     ml = readLine( mapfile )
     importLog = name + "/impfile"
     pl = readLine( importLog )

     if ml.size != pl.size
       puts "Error: " + name
       exit
     end
     for i in 0..ml.size-1
       mll = (ml[i].chomp).split(" ")
       pll = (pl[i].chomp).split(" ")
       newList << sprintf("%s %s", pll[1], mll[1] )
     end
   }
   @gSpace.setHandleID( newList )
 end

 def readLine( filename )
   l = Array.new
   fr = open( filename, "r" )
   fr.each { |line|
     if ((line.chomp).strip).size != 0
       l << (line.chomp).strip
     end
   }
   fr.close
   return l
 end

end
