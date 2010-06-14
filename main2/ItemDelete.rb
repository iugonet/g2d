# -*- coding : utf-8 -*-
require 'fileutils'
require 'tempfile'

require 'main2/Spase2DSpace'


class ItemDelete

 EXC = "Metadata_Draft"
 TempBase = "ImportData_"

 Command = "/opt/dspace/bin/import"
 EMail = "kouno@stelab.nagoya-u.ac.jp"

 MapFormat = "dspace_mapfile_%05d"
 DelTempBase = "ImportData_*"
 DelMapFormat = "dspace_mapfile_*"

 Runfile = "runDelete.sh"

 def initialize( pwd, workDir, gSpace )
  @pwd = pwd
  @workDir = workDir
  @gSpace = gSpace
 end

 def setFileList( deleteList )
   @deleteList = deleteList
 end
 
 def makeDelete()

   frf = @pwd + "/" + Runfile
   fw = open( frf, "w" )
   fw.puts "#!/bin/bash"
   fw.puts ""

   mapfile = @pwd + "/delete_mapfile"
   fm = open( mapfile, "w" )
   rdir = @pwd + "/" + @workDir + "/" +EXC
   len = rdir.length
   for i in 0..@deleteList.size-1
     id = gSpace.getHandleID( deleteList.slice!(0,len+1) )
     fm.printf("%d %s\n", i+1, id )
   end
   fm.close

   fw.printf( "%s -d -e %s -m %s\n",
              Command, EMail, mapfile )
   fw.close
   Dir.chdir( @pwd )
   File.chmod( 0755, frf )
 end

 def runDelete()
    Dir.chdir( @pwd )
    com = sprintf( "./%s", Runfile )
    system( com )
 end

end
