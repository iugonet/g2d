# -*- coding : utf-8 -*-
require 'fileutils'
require 'tempfile'
require 'Spase2DSpace'

class ItemReplacer

 $exc = "/home/odc/kouno/iugonet_git/WorkingDir/Metadata_Draft"
 $log_dir = "/gitlog/test_import"
 $log_filename = "structure"
 $log_

 $tempBase = "ImportData_"

 $command = "/opt/dspace/bin/import"
 $email   = "kouno@stelab.nagoya-u.ac.jp"
 $mapformat = "mapfile%05d"

 def initialize( pwd )
   @pwd = pwd

   @stList = Array.new
   f = @pwd + $log_dir + "/" + $log_filename
   if FileTest.exist?( f )
   fr = open( f, "r" )
   fr.each {|line|
     @stList << (line.chomp).strip
   }
   fr.close
   else
     puts "Error: "
     exit
   end

   @st = Hash.new
   for i in 0..@stList.size-1
     la = @stList[i].split(" ")
     if la.length == 2
        @st[ la[0].strip ] = la[1].strip
     end
   end
 end

 def setFileList( addList,
                  replaceList,
                  deleteList )
   @addList = addList
   @replaceList = replaceList
   @deleteList = deleteList
 end
 
 def test

   s2d = Spase2DSpace.new( Dir.pwd )
   s2d.checkLength
   s2d.getQueryList

   fw = open( "runImport.sh", "w" )
   fw.puts "#/bin/bash"
   fw.puts ""

   ii = 0
   while ( @addList.size > 0 )
     tempFile = Tempfile.new( $tempBase, @pwd)
     tdir = tempFile.path
     tempFile.close(true)
     Dir.mkdir( tdir )


     file = @addList[0]
     dir = File.dirname( file )
     hdir = File.dirname( file )

     len = $exc.length
     hdir.slice!(0,len+1)
     puts hdir
     ha = @st[hdir]
     puts ha

     list  = Array.new
     dlist = Array.new
     list << @addList[0]
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
        j = dlist.size-1 - i
        @addList.delete_at( j )
     end

     for i in 0..list.size-1
        mdir = tdir+"/"+(i+1).to_s
        puts mdir
        Dir.mkdir( mdir )
        FileUtils.install( list[i],mdir,:mode=>0664)
        cfile = mdir+"/"+"contents"
        fwc = open(cfile,"w")
        fwc.puts File.basename(list[i])
        fwc.close

        s2d.conv( list[i], mdir )

     end

     sdir = tdir

     mapfile = sprintf( $mapformat, ii )
     fw.printf("%s -a -e %s -c %s -s %s -m %s\n", $command, $email, ha, sdir, mapfile )
     ii = ii + 1
   end

   fw.close

 end

 def test2
  ii = 0
  ha = ""
  sdir = ""
  mapfile = sprintf( $mapformat, ii )
  com = sprintf("%s -r -e %s -c %s -s %s -m %s\n", $command, $email, ha, sdir, mapfile )
  puts com 


 end

end
