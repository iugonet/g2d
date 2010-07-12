# -*- coding : utf-8 -*-
require 'fileutils'
require 'tempfile'

require 'main2/Spase2DSpace'
require 'main2/DSpace'
require 'util/ScriptMaker'

class ItemReplace

 EXC = "Metadata_Draft"
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
     if la.length == 2
        @stHash[ la[0].strip ] = la[1].strip
     end
   end
 end

 def setFileList( replaceList )
   @replaceList = replaceList
 end

 def make()
   frf = @pwd + "/" + Runfile
   sm = ScriptMaker.new( frf )

   s2d = Spase2DSpace.new( @pwd )
   s2d.checkLength
   s2d.getQueryList

   ii = 0
   while ( @replaceList.size > 0 )
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
        FileUtils.install( list[i],mdir,:mode=>0644)
        cfile = mdir + "/" + "contents"
        fwc = open( cfile, "w" )
        fwc.puts File.basename(list[i])
        fwc.close

        s2d.conv( list[i], mdir )

        llen = list[i].size
        fgl = list[i].slice(len+1,llen-1)
        id = @gSpace.getHandleID( fgl )
        puts "id : " + id.to_s
        fim = tdir + "/mapfile"
        fg = open( fim, "a" )
        fg.printf("%d %s\n", i+1, id )
        fg.close
     end

     sdir = tdir

     mapfile = tdir + "/mapfile"
     cstr = @ds.getReplaceCommand( ha, sdir, mapfile )
     sm.puts( cstr )
     ii = ii + 1
   end

   sm.finalize
   Dir.chdir( @pwd )
 end

 def run
   Dir.chdir( @pwd )
   File.chmod( 0755, Runfile )
   com = sprintf( "./%s", Runfile )
   system( com )
 end

end
