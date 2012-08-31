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

   # Temporary Code
   tmp_checker = "test_umemura/test/PrintDate.sh"
   tmp_command = tmp_checker + " -m "

   system(tmp_command + "Trace-001-001")   # Trace
   frf = @pwd + "/" + Runfile

   system(tmp_command + "Trace-001-002")   # Trace
   sm = ScriptMaker.new( frf )

   system(tmp_command + "Trace-001-003")   # Trace

   system(tmp_command + "Trace-002-001")   # Trace
   s2d = Spase2DSpace.new( @pwd )

   system(tmp_command + "Trace-002-002")   # Trace
   s2d.checkLength

   system(tmp_command + "Trace-002-003")   # Trace
   s2d.getQueryList

   system(tmp_command + "Trace-002-004")   # Trace

   while ( @fileList.size > 0 )

     system(tmp_command + "Trace-003-001")     # Trace
     tempDir = getTempDir

     system(tmp_command + "Trace-003-002")     # Trace
     Dir.mkdir( tempDir )

     system(tmp_command + "Trace-003-003")     # Trace
     mapfile = tempDir + "/mapfile"

     system(tmp_command + "Trace-003-004")     # Trace

     system(tmp_command + "Trace-003-005")     # Trace
     dir = File.dirname( @fileList[0].getRelative )

#    puts "dir = [#{dir}]"     # Debug

     system(tmp_command + "Trace-003-006")     # Trace
     handleID = @stHash[ dir ]
#    puts "handleID = [#{handleID}]"     # Debug (Collection's HandleID)

     system(tmp_command + "Trace-003-007")     # Trace

     system(tmp_command + "Trace-003-008")     # Trace
     addList, delIndexList = getAddList( dir )

     system(tmp_command + "Trace-003-009")     # Trace
     deleteList( delIndexList )

     system(tmp_command + "Trace-003-010")     # Trace

     system(tmp_command + "Trace-004-001")     # Trace
     itemIndex = 0

     system(tmp_command + "Trace-004-002-A")     # Trace

     ######## START: ADD by STEL, N.UMEMURA ########
     hashHandleID = @gSpace.createHandleIDHASH
     ######## END: ADD by STEL, N.UMEMURA   ########

     system(tmp_command + "Trace-004-002-B")     # Trace

     for i in 0..addList.size-1

       system(tmp_command + "Trace-004-003")       # Trace

       if i%30000 == 29999

          system(tmp_command + "Trace-004-004")          # Trace
          cstr = @ds.getReplaceCommand( handleID, tempDir, mapfile )

          system(tmp_command + "Trace-004-005")          # Trace
          sm.puts( cstr )

          system(tmp_command + "Trace-004-006")          # Trace
          tempDir = getTempDir

          system(tmp_command + "Trace-004-007")          # Trace
          Dir.mkdir( tempDir )

          system(tmp_command + "Trace-004-008")          # Trace
          mapfile = tempDir + "/mapfile"

          system(tmp_command + "Trace-004-009")          # Trace
          itemIndex = 0

          system(tmp_command + "Trace-004-010")          # Trace

       end

       system(tmp_command + "Trace-004-011")       # Trace
       itemIndex = itemIndex + 1

       system(tmp_command + "Trace-004-012")       # Trace
       afile = addList[i].getAbsolute

#      puts "afile = [#{afile}]"       # Debug

       system(tmp_command + "Trace-004-013")       # Trace
       rfile = addList[i].getRelative

#      puts "rfile = [#{rfile}]"       # Debug

       system(tmp_command + "Trace-004-014")       # Trace
       itemDir = tempDir + "/" + itemIndex.to_s

       system(tmp_command + "Trace-004-015")       # Trace
       Dir.mkdir( itemDir )

       system(tmp_command + "Trace-004-016")       # Trace
       FileUtils.install( afile, itemDir, :mode=>0644 )

       system(tmp_command + "Trace-004-017")       # Trace
       makeContentsFile( itemDir, afile )

       system(tmp_command + "Trace-004-018")       # Trace
       s2d.conv( afile, itemDir )

       system(tmp_command + "Trace-004-019-A")       # Trace

       ######## START: ADD by STEL, N.UMEMURA ########
       handleIDMD = hashHandleID[rfile]      # Metadata's HandleID
       puts "handleIDMD = [#{handleIDMD}]"
       ######## END: ADD by STEL, N.UMEMURA   ########

       system(tmp_command + "Trace-004-019-B")       # Trace

       writeMapfile2( mapfile, itemIndex, rfile, handleIDMD )
#      writeMapfile( mapfile, itemIndex, rfile )   ### TOO LATE!!!

       system(tmp_command + "Trace-004-020")       # Trace

     end

     system(tmp_command + "Trace-005-001")     # Trace
     cstr = @ds.getReplaceCommand( handleID, tempDir, mapfile )

     system(tmp_command + "Trace-005-002")     # Trace
     sm.puts( cstr )

     system(tmp_command + "Trace-005-003")     # Trace

   end

   system(tmp_command + "Trace-006-001")   # Trace
   sm.finalize

   system(tmp_command + "Trace-006-002")   # Trace
   Dir.chdir( @pwd )

   system(tmp_command + "Trace-006-003")   # Trace

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

   # Debug
#  puts "@fileList.size = [#{@fileList.size}]"

   for i in 0..@fileList.size-1
     file = @fileList[i].getRelative

     # Debug
#    puts "i    = [#{i}]"
#    puts "file = [#{file}]"

     dir = File.dirname( file )

     # Debug
#    puts "dir    = [#{dir}]"
#    puts "addDir = [#{addDir}]"

     if dir == addDir
       # Debug
#      puts "MATCHING!!!"
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

   # Temporary Code
   tmp_checker = "test_umemura/test/PrintDate.sh"
   tmp_command = tmp_checker + " -m "

   system(tmp_command + "Trace-101-001")   # Trace
   handleID = @gSpace.getHandleID( file )  ### TOO LATE!!!

   system(tmp_command + "Trace-101-002")   # Trace
   fw = open( mapfile, "a" )

   system(tmp_command + "Trace-101-003")   # Trace
   fw.printf( "%d %s\n", i, handleID )

   system(tmp_command + "Trace-101-004")   # Trace
   fw.close

   system(tmp_command + "Trace-101-005")   # Trace

 end

 def writeMapfile2( mapfile, i, file, handleID )

   # Temporary Code
   tmp_checker = "test_umemura/test/PrintDate.sh"
   tmp_command = tmp_checker + " -m "

   system(tmp_command + "Trace-101-001")   # Trace
#  handleID = @gSpace.getHandleID( file )  ### TOO LATE!!!

   system(tmp_command + "Trace-101-002")   # Trace
   fw = open( mapfile, "a" )

   system(tmp_command + "Trace-101-003")   # Trace
   fw.printf( "%d %s\n", i, handleID )

   system(tmp_command + "Trace-101-004")   # Trace
   fw.close

   system(tmp_command + "Trace-101-005")   # Trace

 end

 def run
   Dir.chdir( @pwd )
   File.chmod( 0755, Runfile )
   com = sprintf( "./%s", Runfile )
   system( com )
 end

end
