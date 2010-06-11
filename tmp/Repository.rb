# -*- coding : utf-8 -*-
require 'fileutils'
require 'tempfile'

class Repository

 Commit_log = "Commit.log"
 Change_log = "change.log"

 GitCommand = "git"
 WorkDirectory = "WorkDir"

 def initialize( pwd, repoList )
   @pwd = pwd
   @repoList = repoList

   @gitCommand = GitCommand
   makeWorkDir()

   @repoWorkDirList = Array.new
   for i in 0..repoList.size-1
    d = repoList[i].split(/\//)
    str = @wd + "/" + d[0]
    for j in 1..d.size-2
      str = str + "_" + d[j]
    end
    @repoWorkDirList << str
   end

   @repo = Array.new
   for i in 0..@repoWorkDirList.size-1
     @repo << @repoWorkDirList[i] + "/" + File.basename( @repoList[i], ".git" )
   end

   FileUtils.mkdir_p( @repoWorkDirList.uniq )
 end

 def makeWorkDir
   wd = @pwd + "/" + WorkDirectory
   if FileTest.exist?(wd)
     if FileTest.directory?(wd)
       puts "working dir: " + wd
     else
       puts "Error: " + wd + " file exists"
       exit
     end
   else
     Dir.mkdir( wd )
     puts "mkdir: " + wd
   end
   @wd = wd
 end

 def setCommandPath( gitCommand )
   @gitCommand = gitCommand
 end

 def gitPull( host, user )
   Dir.chdir( @wd )
   gitsh = @wd + "/" + "git.sh"
   fw = open( gitsh, "w" )
   fw.puts "#!/bin/bash"
   fw.puts ""
   for i in 0..@repoWorkDirList.size-1
     if FileTest.exist?( @repo[i] )
       fw.printf( "cd %s\n", @repo[i] )
       fw.printf( "%s pull\n", @gitCommand )
     else
       fw.printf( "cd %s\n", @repoWorkDirList[i] )
       fw.printf( "%s clone ssh://%s@%s/~/git/%s\n",
                  @gitCommand, user, host, @repoList[i] )
     end
   end
   fw.close
   File.chmod( 0755, gitsh )

   system( gitsh )
 end

 def gitCommitLog
   @commitFileList = Array.new
   for i in 0..@repo.size-1
     Dir.chdir( @repo[i] )
     d = File.dirname( @repoList[i] )
     r = d.gsub(/[\/]/,'_')
     b = File.basename( @repoList[i], ".git" )
     filename = @wd + "/" + r + "_" + b + "_" + Commit_log
     @commitFileList << filename
     gcom = sprintf( "%s log | grep commit > %s",
                     @gitCommand, filename )
     system( gcom )
   end
 end

 def setGitDSpace( gSpace )
   @gSpace = gSpace
 end

 def git

  for i in 0..@commitFileList.size-1

    now_id = @gSpace.getCommitID( i )

    Dir.chdir( @repo[i] )
    commitLineList = Array.new
    fr = open( @commitFileList[i], "r" )
    fr.each { |line|
      commitLineList << (line.chomp).strip
    }
    fr.close
    i_id = commitLineList.size
    for k in 0..commitLineList.size-1
       if commitLineList[k].include?(now_id)
          i_id = k
       end
    end

    h = Hash.new

     for ii in 0..i_id-1
       j = i_id-1-ii
       tempf1 = Tempfile.new( "commit_", @wd )
       tempfile1 = tempf1.path
       tempf1.close
       tempf2 = Tempfile.new( "commit_", @wd )
       tempfile2 = tempf2.path
       tempf3 = Tempfile.new( "commit_", @wd )
       tempfile3 = tempf3.path

       lt = commitLineList[j].split(" ")
       id = lt[1].strip
       gcom1 = sprintf( "%s show --pretty=oneline --summary %s > %s",
                        @gitCommand, id, tempfile1 )
       gcom2 = sprintf( "%s show --pretty=oneline --stat %s > %s",
                        @gitCommand, id, tempfile2 )
       gcom3 = sprintf( "%s show --pretty=oneline -p %s > %s",
                        @gitCommand, id, tempfile3 )
       system( gcom1 )
       system( gcom2 )
       system( gcom3 )

=begin
       tempf1.open
       skip = true
       tempf1.each { |line|
         if skip
           skip = false
         else
           if line.include?(".xml") || line.include?(".XML")
             if line.include?("create")
               lt = (line.chomp).split(" ")
               key = (lt[lt.size-1]).strip
               if h[ key ] == nil
                 h[ key ] = "add"
               else
                 v = h[ key ]
                 h[ key ] = v+",add"
               end
             elsif line.include?("delete")
               lt = (line.chomp).split(" ")
               key = (lt[lt.size-1]).strip
               if h[ key ] == nil
                 h[ key ] = "remove"
               else
                 v = h[ key ]
                 h[ key ] = v+",remove"
               end
             else
             end
           end
         end
       }
       tempf1.close
=end
=begin
       tempf2.open
       skip = true
       tempf2.each { |line|
         if skip
           skip = false
         else
           if line.include?("|") &&
            ( line.include?(".xml") || line.include?(".XML") )
             fl = (line.chomp).split("|")
             key = fl[0].strip
             h[ key ] = "replace"
           end
         end
       }
       tempf2.close
=end

       tempf3.open
       skip = true
       ld = Array.new
       scan = false
       tempf3.each { |line|
         if skip
            skip = false
         else
            if line.include?("diff --git ") &&
             ( line.include?(".xml") || line.include?(".XML") )
              ld << line
              scan = true
            elsif scan && ( line.include?("new") ||
                            line.include?("deleted") )
              ld << line
              scan = false
            elsif line.include?("index")
              scan = false
            end
=begin
            if line.include?("diff --git ") &&
             ( line.include?(".xml") || line.include?(".XML") )
             fl = (line.chomp).split(" ")
             key = fl[3].strip
             key[0..1] = ""
             if h[ key ] == nil
               h[ key ] = "replace"
             else
               v = h[ key ]
               h[ key ] = v+",replace"
             end
            end
=end
         end
       }
       for k in 0..ld.size-1
         if ld[k].include?(".xml") || ld[k].include?(".XML")
           if k < ld.size-1
             if ld[k+1].include?("new")
               fl = (ld[k].chomp).split(" ")
               key = fl[3].strip
               key[0..1] = ""
               if h[ key ] == nil
                  h[ key ] = "add"
               else
                  v = h[ key ]

                  vs = v.split(",")
                  if vs[vs.size-1] == "remove"
                    h[ key ] = v+",add"
                  else
                    h[ key ] = v+",replace"
                  end
               end
             elsif ld[k+1].include?("deleted")
               fl = (ld[k].chomp).split(" ")
               key = fl[3].strip
               key[0..1] = ""
               if h[ key ] == nil
                  h[ key ] = "delete"
               else
                  v = h[ key ]
                  h[ key ] = v+",delete"
               end
             else
               fl = (ld[k].chomp).split(" ")
               key = fl[3].strip
               key[0..1] = ""
               if h[ key ] == nil
                  h[ key ] = "replace"
               else
                  v = h[ key ]
                  h[ key ] = v+",replace"
               end
             end
           else
               fl = (ld[k].chomp).split(" ")
               key = fl[3].strip
               key[0..1] = ""
               if h[ key ] == nil
                  h[ key ] = "replace"
               else
                  v = h[ key ]
                  h[ key ] = v+",replace"
               end
           end
         end
       end
       tempf3.close

#    @glog.setCommitID( i, commitLineList[j] )

    end
    fname = @wd+"/"+Change_log
    fw = open( fname, "a" )
    h.each { |key,value|
      fw.puts @repo[i]+"/"+key + " : " + value
      puts key + " : " + value
    }
    fw.close
  end

 end


end
