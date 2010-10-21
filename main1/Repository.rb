# -*- coding : utf-8 -*-
require 'fileutils'
require 'tempfile'

require 'main1/Git'
require 'util/ScriptMaker'

class Repository

 Commit_log = "_Commit.log"
 Change_log = "Change.log"

 WorkDirectory = "WorkDir"

 def initialize( pwd, repoList )
   @pwd = pwd
   @repoList = repoList

   makeWorkDir()

   @repoWorkDirList = Array.new
   for i in 0..repoList.size-1
    d = File.dirname( @repoList[i] )
    str = @wd + "/" + d.gsub(/[\/]/,'_')
    @repoWorkDirList << str
   end

   @repo = Array.new
   for i in 0..@repoWorkDirList.size-1
     @repo << @repoWorkDirList[i] + "/" + File.basename( @repoList[i], ".git" )
   end

   FileUtils.mkdir_p( @repoWorkDirList.uniq )
 end

 def initGit( host, user )
   @git = Git.new( user, host )
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

 def gitPull()
   Dir.chdir( @wd )
   gitsh = @wd + "/" + "git.sh"
   sc = ScriptMaker.new( gitsh )
   for i in 0..@repoWorkDirList.size-1
     if FileTest.exist?( @repo[i] )
       sc.puts( sprintf("cd %s", @repo[i] ) )
       sc.puts( @git.getPullCommand() )
     else
       sc.puts( sprintf( "cd %s", @repoWorkDirList[i] ) )
       sc.puts( @git.getCloneCommand( @repoList[i] ) )
     end
   end
   sc.finalize
   File.chmod( 0755, gitsh )
   system( gitsh )
   Dir.chdir( @pwd )
 end

 def gitCommitLog
   @commitFileList = Array.new
   for i in 0..@repo.size-1
     Dir.chdir( @repo[i] )
     f = @repoList[i].gsub(/[\/]/,'_')
     b = File.basename( f, ".git" )
     filename = @wd + "/" + b + Commit_log
     @commitFileList << filename
     gcom = @git.getLogCommand( filename )
     system( gcom )
   end
   Dir.chdir( @pwd )
 end

 def setGitDSpace( gSpace )
   @gSpace = gSpace
 end

 def getWorkDir()
   return WorkDirectory
 end

 def getChangeList

   fname = @pwd+"/"+Change_log

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
       tempf = Tempfile.new( "commit_", @wd )
       tempfile = tempf.path
       tempf.close

       lt = commitLineList[j].split(" ")
       id = lt[1].strip
       gcom = @git.getShowCommand( id, tempfile )
       system( gcom )
       tempf.open
       skip = true
       ld = Array.new
       scan = false
       tempf.each { |line|
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
       tempf.close(true)
       @gSpace.setCommitID( i, commitLineList[j] )
     end

     writeChangeLog( fname, @repo[i], h )
   end
 end

 def writeChangeLog( filename, rdir, hash )
   Dir.chdir( @pwd )
   fw = open( filename, "a" )
   hash.each { |key,value|
     fw.puts rdir+"/"+key + " : " + value
   }
   fw.close
 end

end
