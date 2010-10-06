# -*- coding : utf-8 -*-
require 'fileutils'
require 'tempfile'

require 'main2/Spase2DSpace'
require 'main2/DSpace'
require 'util/ScriptMaker'

class ItemDelete

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
 def setRepoDirList( repoDirList )
   @repoDirList = repoDirList
 end
 
 def make()
   frf = @pwd + "/" + Runfile
   sm = ScriptMaker.new( frf )

   tdir = @pwd + "/" + TempDir
   Dir.mkdir( tdir )
   mapfile = tdir + "/mapfile"
   fm = open( mapfile, "w" )

   for i in 0..@deleteList.size-1
     file = @deleteList[i]
     dir = File.dirname( file )
     hdir = File.dirname( file )
     for j in 0..@repoDirList.size-1
       repository = @repoDirList[i]
       newRepositoryName = File.basename(repository,".git")
       repositoryDir     = File.dirname(repository)
       newRepositoryDir = repositoryDir.gsub(/[\/]/,'_')
       repositoryAbsolutePath = @pwd + "/" + @workDir + "/" + newRepositoryDir + "/" + newRepositoryName
       if  hdir.include?( repositoryAbsolutePath )
         len = repositoryAbsolutePath.length
         hdir.slice!(0,len+1)
         break
       end
     end
     llen = @deleteList[i].size
     fgl = @deleteList[i].slice(repositoryAbsolutePath.length+1,llen-1)
     id = @gSpace.getHandleID( fgl )
     fm.printf("%d %s\n", i+1, id )
     @gSpace.deleteHandleID2( fgl, id )
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
