# -*- coding : utf-8 -*-
require 'fileutils'
require 'tempfile'

require 'main2/Spase2DSpace'
require 'main2/DSpace'
require 'util/ScriptMaker'

class ItemDelete

 EXC = "Metadata_Draft"
 TempDir = "DeleteData"
 Runfile = "runDelete.sh"

 def initialize( pwd, workDir, gSpace )
  @pwd = pwd
  @workDir = workDir
  @gSpace = gSpace

  @ds = DSpace.new( @pwd )
 end

 def setFileList( deleteList )
   @deleteList = deleteList
 end
 
 def make()
   frf = @pwd + "/" + Runfile
   sm = ScriptMaker.new( frf )

   tdir = @pwd + "/" + TempDir
   Dir.mkdir( tdir )
   mapfile = tdir + "/mapfile"
   fm = open( mapfile, "w" )
   rdir = @pwd + "/" + @workDir + "/" + EXC
   len = rdir.length
   for i in 0..@deleteList.size-1
     @deleteList[i].slice!(0,len+1)
     id = @gSpace.getHandleID( @deleteList[i] )
     fm.printf("%d %s\n", i+1, id )
     @gSpace.deleteHandleID2( @deleteList[i], id )
   end
   fm.close

   if @deleteList.size > 0
     cstr = @ds.getDeleteCommand( mapfile )
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

 def updateMapfile()
 end

end
