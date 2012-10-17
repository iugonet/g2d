# -*- coding : utf-8 -*-
require 'fileutils'
require 'tempfile'

require 'main2/FileList'
require 'main2/Spase2DSpace'
require 'main2/DSpace'
require 'util/ScriptMaker'

class ItemReplace

 TempBase = "ReplaceData_"
 Runfile = "runReplace.sh"

 # Add by N.UMEMURA, 20121016
 SkipFile = "skip.out"
 ComSkip  = "echo %s >> " + SkipFile

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

   while ( @fileList.size > 0 )
     tempDir = getTempDir
     Dir.mkdir( tempDir )
     mapfile = tempDir + "/mapfile"

     dir = File.dirname( @fileList[0].getRelative )
     handleID = @stHash[ dir ]   ## Collection's Handle

     addList, delIndexList = getAddList( dir )
     deleteList( delIndexList )

     ######## START: ADD by STEL N.UMEMURA, 20120823 ########
     hashHandleID = @gSpace.createHandleIDHASH
     ######## END  : ADD by STEL N.UMEMURA, 20120823 ########

     itemIndex = 0
     for i in 0..addList.size-1
       if i%30000 == 29999
         # Mod by N.UMEMURA, 20121011         
         if File.exist?(mapfile)
           filesize = File::stat(mapfile).size
           if filesize != 0
             cstr = @ds.getReplaceCommand( handleID, tempDir, mapfile )
             sm.puts( cstr )
           end
         end
         ## Old Code
=begin
         cstr = @ds.getReplaceCommand( handleID, tempDir, mapfile )
         sm.puts( cstr )
=end
         tempDir = getTempDir
         Dir.mkdir( tempDir )
         mapfile = tempDir + "/mapfile"
         itemIndex = 0
       end

       #### START: MOD Flow-Chart by N.UMEMURA, 20121011

       # Get File Attribute
       afile = addList[i].getAbsolute
       rfile = addList[i].getRelative

       # Get HandleID
       handleIDMD = hashHandleID[rfile]        ## Metadata's HandleID

       # Judge and Exec
       if handleIDMD == nil || handleIDMD == ""
         puts "##ERROR> ItemReplace.rb#make(): HandleID is Not Found in ItenHandle.log!"
         puts "##ERROR> Skip this File. ------> See Log File: \'skip.out\'"
         puts "##ERROR> rfile      = [#{rfile}]"
         puts "##ERROR> handleIDMD = [#{handleIDMD}]"
         system(sprintf(ComSkip, rfile))      ## Write Log
       else
         # Create Directory
         itemIndex = itemIndex + 1
         itemDir = tempDir + "/" + itemIndex.to_s
         Dir.mkdir( itemDir )
         # Set SPASE-XML File into the Directory
         FileUtils.install( afile, itemDir, :mode=>0644 )
         makeContentsFile( itemDir, afile )
         # Convert SPASE-XML to Dublin-Core-XML, and Set DC-XML into the Directory
         s2d.conv( afile, itemDir )
         # Write HandleID into mapfile
         writeMapfile2( mapfile, itemIndex, rfile, handleIDMD )
       end

       ## Old Code
=begin
       itemIndex = itemIndex + 1
       afile = addList[i].getAbsolute
       rfile = addList[i].getRelative
       itemDir = tempDir + "/" + itemIndex.to_s
       Dir.mkdir( itemDir )
       FileUtils.install( afile, itemDir, :mode=>0644 )
       makeContentsFile( itemDir, afile )
       s2d.conv( afile, itemDir )

       ######## START: ADD by STEL N.UMEMURA, 20120823 ########
       handleIDMD = hashHandleID[rfile]        ## Metadata's HandleID
#      puts "handleIDMD = [#{handleIDMD}]"
       ######## END  : ADD by STEL N.UMEMURA, 20120823 ########

       ######## START: MOD by STEL N.UMEMURA, 20120823 ########
#      writeMapfile( mapfile, itemIndex, rfile )
       writeMapfile2( mapfile, itemIndex, rfile, handleIDMD )
       ######## END  : MOD by STEL, N.UMEMURA 20120823 ########
=end

       #### END: MOD Flow-Chart by N.UMEMURA, 20121011

     end

     # Mod by N.UMEMURA, 20121011
     if File.exist?(mapfile)
       filesize = File::stat(mapfile).size
       if filesize != 0
         cstr = @ds.getReplaceCommand( handleID, tempDir, mapfile )
         sm.puts( cstr )
       end
     end

     ## Old Cole
=begin
     cstr = @ds.getReplaceCommand( handleID, tempDir, mapfile )
     sm.puts( cstr )
=end
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
   filename = mdir + "/contents"
   fwc = open( filename, "w" )
   fwc.puts File.basename( file )
   fwc.close
 end

 def writeMapfile( mapfile, i, file )
   handleID = @gSpace.getHandleID( file )
   fw = open( mapfile, "a" )
   fw.printf( "%d %s\n", i, handleID )
   fw.close
 end

 ######## START: ADD by STEL N.UMEMURA, 20120823 ########
 def writeMapfile2( mapfile, i, file, handleID )
   fw = open( mapfile, "a" )
   fw.printf( "%d %s\n", i, handleID )
   fw.close
 end
 ######## END  : ADD by STEL N.UMEMURA, 20120823 ########

 def run
   Dir.chdir( @pwd )
   File.chmod( 0755, Runfile )
   com = sprintf( "./%s", Runfile )
   system( com )
 end

end
