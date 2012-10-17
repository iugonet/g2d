# -*- coding : utf-8 -*-
require 'fileutils'
require 'tempfile'

require 'main2/FileList'
require 'main2/Spase2DSpace'
require 'main2/DSpace'
require 'util/ScriptMaker'
require 'main1/HandleID'

class ItemDelete

 TempDir = "DeleteData"
 Runfile = "runDelete.sh"

 # Add by N.UMEMURA, 20121016
 SkipFile = "skip.out"
 ComSkip  = "echo %s >> " + SkipFile

 def initialize( pwd, workDir, gSpace )
  @pwd = pwd
  @workDir = workDir
  @gSpace = gSpace
 end

 def setFileList( fileList )
    @fileList = fileList
 end

 def make()
   tempDir = @pwd + "/" + TempDir
   Dir.mkdir( tempDir )
   mapfile = tempDir + "/mapfile"
   logfile = tempDir + "/logfile"
   lm = open( logfile, "w" )

   delList = Array.new
   hid = HandleID.new( @gSpace.getItemHandleFile )
   hid.read

   #### START: Add by N.UMEMURA, 20121010 ####
   enumber = 0   # Number of Error.
   iout    = 0   # Count Up, Only When HandleID is Found in ItemHandle.log.
   #### END:   Add by N.UMEMURA, 20121010 ####

   fm = open( mapfile, "w" )
   for i in 0..@fileList.size-1
     filename = @fileList[i].getRelative
     id, n = hid.getID( filename )
     # START: Add by N.UMEMURA, 20121010.
     # Skips, when HandleID is NOT found in ItemHandle.log.
     if id == nil || n == nil || id == "" || n == ""
       puts "##ERROR> ItemDelete.rb#make(): HandleID is Not Found in ItenHandle.log!"
       puts "##ERROR> Skip this File. ------> See Log File: \'skip.out\'"
       puts "##ERROR> filename = [#{filename}]"
       puts "##ERROR> id = [#{id}]"
       puts "##ERROR> n  = [#{n}]"
       system(sprintf(ComSkip, filename))      ## Write Log
       enumber = enumber + 1
     # END: Add by N.UMEMURA, 20121010
     else
       lm.printf("%s\n", filename )
       iout = iout + 1                   # Count Up. Add by N.UMEMURA, 20121010
       fm.printf("%d %s\n", iout, id )   # Mod by N.UMEMURA, 20121010
#      fm.printf("%d %s\n", i+1, id )
       delList << n
     end
   end
   fm.close
   lm.close
   hid.delete( delList )
   hid.write

   frf = @pwd + "/" + Runfile
   sm = ScriptMaker.new( frf )
#  if @fileList.size > 0                 # Mod by N.UMEMURA, 20121010
   if @fileList.size - enumber > 0       # Mod by N.UMEMURA, 20121010
     ds = DSpace.new( @pwd )
     cstr = ds.getDeleteCommand( mapfile )
     sm.puts( cstr )
   end
   sm.finalize

   Dir.chdir( @pwd )
 end

 def run()
   Dir.chdir( @pwd )
   File.chmod( 0755, Runfile )
   com = sprintf( "./%s", Runfile )
   system( com )
 end

 def checkDirectory()
   tempDir = @pwd + "/" + TempDir
   logfile = tempDir + "/logfile"
   deleteFileList = Array.new
   lm = open( logfile, "r" )
   lm.each { |line|
     deleteFileList << (line.chomp).strip
   }
   lm.close

   deleteDirList = Array.new
   for i in 0..deleteFileList.size-1
     deleteDirList << File.dirname( deleteFileList[i] )
   end

   deleteDirList.uniq!

   deleteList = @gSpace.getDeleteStructureList( deleteDirList )  


   frf = @pwd + "/runClean.sh"
   sm = ScriptMaker.new( frf )
   ds = DSpace.new( @pwd )

   for i in 0..deleteList.size-1
     dir = deleteList[i].split("/")
     for j in 0..dir.size-2
       n = dir.size-1-j
       dirname = ""
       for k in 0..n
         dirname = dirname + dir[k]
         if k != n
           dirname = dirname + "/"
         end
       end
       community_id, collection_id = @gSpace.deleteStructure( dirname )
       if community_id.size > 0 && collection_id.size > 0
         cstr = ds.getDeleteCollectionCommand( community_id, collection_id )
         sm.puts( cstr )
       elsif community_id.size > 0 && collection_id.size == 0
         cstr = ds.getDeleteCommunityCommand( community_id )
         sm.puts( cstr )
       end
     end
   end
   sm.finalize
 end

 def runClean()
   Dir.chdir( @pwd )
   File.chmod( 0755, "runClean.sh" )
   com = sprintf( "./%s", "runClean.sh" )
   system( com )
 end

end
