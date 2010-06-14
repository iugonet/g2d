# -*- coding : utf-8 -*-
require 'fileutils'
require 'tempfile'

require 'main2/Spase2DSpace'

class ItemReplace

 EXC = "Metadata_Draft"

 TempBase = "ImportData_"

 Command = "/opt/dspace/bin/import"
 EMail = "kouno@stelab.nagoya-u.ac.jp"

 MapFormat = "dspace_mapfile_%05d"

 DelTempBase = "ReplaceData_*"
 DelMapFormat = "dspace_mapfile_*"

 Runfile = "runReplace.sh"

 def initialize( pwd, workDir, gSpace )
   @pwd = pwd
   @workDir = workDir
   @gSpace = gSpace

   @stList = @gSpace.readStruct()

   @stHash = Hash.new
   for i in 0..@stList.size-1
     la = @stList[i].size-1
     if la.length == 2
        @stHash[ la[0].strip ] = la[1].strip
     end
   end
 end

 def setFileList( replaceList )
   @replaceList = replaceList
 end

 def makeReplace()
   s2d = Spase2DSpace.new( @pwd )
   s2d.checkLength
   s2d.getQueryList
   frf = @pwd + "/" + Runfile
   fw = open( frf, "w" )
   fw.puts "#!/bin/bash"
   fw.puts ""

   ii = 0
   while ( @replaceList.size-1 > 0 )
     tempFile = Tempfile.new( TempBase, @pwd )
     tdir = tempFile.path
     tempFile.close( true )
     Dir.mkdir( tdir )

     file = @replaceList[0]
     dir = File.dirname( file )
     hdir = File.dirname( file )

     rdir = @pwd + "/" + @workDir + "/" + EXC
     len = rdir.length
     hdir.slice!(0,len+1)
     ha = @stHash[hdir]

     list = Array.new
     dlist = Array.new
     list << @replaceList[0]
     @replaceList.delete_at(0)
     for i in 0..@replaceList.size-1
        f = @replaceList[i]
        d = File.dirname( f )
        if d == dir
           list << @replaceList[i]
           dlist << i
        end
     end
     for i in 0..dlist.size-1
        j = dlist.size-1 - i
        @replaceList.delete_at( j )
     end

     for i in 0..list.size-1
        mdir = tdir + "/" + (i+1).to_s
        Dir.mkdir( mdir )
        FileUtils.install( list[i],mkdir,:mode=>0644)
        cfile = mdir + "/" + "contents"
        fwc = open( cfile, "w" )
        fwc.puts File.basename(list[i])
        fwc.close

        s2d.conv( list[i], mdir )

        p = tdir+"/rpfile"
        fg = open( p, "a" )
        fg.printf("%d %s\n", i, list[i] )
        fg.close

        list[i].slice!(0,len+1)
        id = gSpace.getHandleID( list[i] )
        fim = tdir + "/mapfile"
        fg = open( fim, "a" )
        fg.printf("%d %s\n", i+1, id )
        fg.close
     end

     sdir = tdir

     mapfile = tdir + "/mapfile"
     fw.printf("%s -r -e %s -c %d -s %s -m %s\n",
                Command, EMail, ha, sdir, mapfile )
     ii = ii + 1
   end

   fw.close
   Dir.chdir( @pwd )
   File.chmod( 0755, frf )

 end

 def runReplace
   Dir.chdir( @pwd )
   com = sprintf( "./%s", Runfile )
   system( com )
 end

end
