# -*- coding : utf-8 -*-
require 'fileutils'
require 'tempfile'

require 'main2/Spase2DSpace'
require 'main2/DSpace'
require 'util/ScriptMaker'


class ItemImport

 EXC = "Metadata_Draft"
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
     if la.length == 2
        @stHash[ la[0].strip ] = la[1].strip
     end
   end
 end

 def setFileList( addList )
   @addList = addList
 end
 
 def make()
   frf = @pwd + "/" + Runfile
   sm = ScriptMaker.new( frf )

   s2d = Spase2DSpace.new( @pwd )
   s2d.checkLength
   s2d.getQueryList

   ii = 0
   while ( @addList.size > 0 )
     tempFile = Tempfile.new( TempBase, @pwd)
     tdir = tempFile.path
     tempFile.close(true)
     Dir.mkdir( tdir )


     file = @addList[0]
     dir = File.dirname( file )
     hdir = File.dirname( file )

     rdir = @pwd + "/" + @workDir + "/" + EXC
     len = rdir.length
     hdir.slice!(0,len+1)
     ha = @stHash[hdir]

     list  = Array.new
     dlist = Array.new
     list << file
     @addList.delete_at(0)
     for i in 0..@addList.size-1
        f = @addList[i]
        d = File.dirname( f )
        if d == dir
          list << @addList[i]
         dlist << i
        end
     end

     for i in 0..dlist.size-1
       j = dlist.size-1-i
       @addList.delete_at( dlist[j] )
     end

     for i in 0..list.size-1
        mdir = tdir+"/"+(i+1).to_s
        Dir.mkdir( mdir )
        FileUtils.install( list[i],mdir,:mode=>0664)
        cfile = mdir+"/"+"contents"
        fwc = open(cfile,"w")
        fwc.puts File.basename(list[i])
        fwc.close

        s2d.conv( list[i], mdir )

        p = tdir+"/impfile"
        fg = open( p, "a" )
        llen = list[i].size
        fgl = list[i].slice(len+1,llen-1)
        fg.printf( "%d %s\n", i, fgl )
        fg.close
     end

     sdir = tdir

     mapfile = tdir + "/mapfile"
     cstr = @ds.getImportCommand( ha, sdir, mapfile )
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

 def setMapfile
   newList = Array.new
   Dir.glob(TempBaseAll).each{|name|
     ml = Array.new
     pl = Array.new
     mapfile = name + "/mapfile"
     fr = open( mapfile, "r" )
     fr.each {|line|
       if ((line.chomp).strip).size != 0
         ml << (line.chomp).strip
       end
     }
     fr.close
     p = name + "/impfile"
     fr = open( p, "r" )
     fr.each {|line|
       if ((line.chomp).strip).size != 0
         pl << (line.chomp).strip
       end
     }
     fr.close
     if ml.size != pl.size
       puts "Error: " + name
       exit(0)
     end
     for i in 0..ml.size-1
       mll = (ml[i].chomp).split(" ")
       pll = (pl[i].chomp).split(" ")
       newList << sprintf("%s %s", pll[1], mll[1] )
     end
   }
   @gSpace.setHandleID( newList )
 end

end
