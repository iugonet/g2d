# -*- coding : utf-8 -*-

require 'fileutils'

class GitDSpace

 Git_conf = "conf/gitdspace.conf"
 Commit_log          = "Commit.log"
 ItemHandle_log      = "ItemHandle.log"
 StructureHandle_log = "StructureHandle.log"

 GitCommand = "git"

 GitDirectory = "GitDSpace"

 def initialize( pwd, repoList )
   @pwd = pwd
   @repoList = repoList

   @gitCommand = GitCommand

   makeGitDir()
   readConf()
 end

 def makeGitDir()
   gd = @pwd + "/" + GitDirectory
   if FileTest.exist?(gd)
     if FileTest.directory?(gd)
        puts "git dir: " + gd
     else
       puts "Error: " + gd + "file exists"
       exit
     end
   else
     Dir.mkdir( gd )
     puts "mkdir: " + gd
   end
   @gwd = gd
   puts "Git Dir: " + @gwd
 end

 def getGitDir()
   return @gwd
 end

 def readConf()
   f = @pwd + "/" + Git_conf
   fr = open( f, "r" )
   fr.each { |line|
     lt = (line.chomp).split(/=/)
     if lt[0].strip == "HOST"
       @host = lt[1].strip
     elsif lt[0].strip == "USER"
       @user = lt[1].strip
     elsif lt[0].strip == "REPO"
       @repoPath = lt[1].strip
     end
   }
   fr.close
 end

 def setCommandPath( gitCommand )
   @gitCommand = gitCommand
 end

 def gitPull
   Dir.chdir( @gwd )
   dir = File.basename( @repoPath, ".git" )
   @repoDir = @gwd+"/"+dir
   if FileTest.exist?( @repoDir )
      Dir.chdir( @repoDir )
      com = sprintf( "%s pull", @gitCommand )
      system( com )
   else
      com = sprintf( "%s clone ssh://%s@%s/~/git/%s\n",
                    @gitCommand, @user, @host, @repoPath )
      system( com )
   end
 end

 def init
   Dir.chdir( @gwd )

   @commitFileList = Array.new
   for i in 0..@repoList.size-1
     d = File.dirname( @repoList[i] )
     r = d.gsub(/[\/]/,'_')
     b = File.basename( @repoList[i], ".git" )
     cf = @repoDir + "/" + r + "_" + b + "_" + Commit_log
     if !FileTest.exist?( cf )
       puts "init file: " + cf
       fr = open( cf, "w" )
       fr.close
     end
     @commitFileList << cf
   end
   hf = @repoDir + "/" + ItemHandle_log
   sf = @repoDir + "/" + StructureHandle_log
   if !FileTest.exist?( hf )
     puts "init file: " + hf
     fr = open( hf, "w" )
     fr.close
   end
   if !FileTest.exist?( sf )
     puts "init file: " + sf
     fr = open( sf, "w" )
     fr.close
   end
   @itemHandleFile = hf
   @structureHandleFile = sf
   Dir.chdir( @pwd )
 end

 def gitPush( message )
   com1 = sprintf( "%s add .", @gitCommand )
   com2 = sprintf( "%s commit -am \"%s\"", @gitCommand, message )
   com3 = sprintf( "%s push", @gitCommand )
   Dir.chdir( @repoDir )
   system( com1 )
   system( com2 )
   system( com3 )
   Dir.chdir( @pwd )
 end

 def readStruct()
   stList = Array.new
   fr = open( @structureHandleFile, "r" )
   fr.each { |line|
     stList << (line.chomp).strip
   }
   fr.close
   return stList
 end

 def writeStruct( list )
   stList = Array.new
   fr = open( @structureHandleFile, "r" )
   fr.each { |line|
     stList << (line.chomp).strip
   }
   fr.close
   wList = stList + list
   wList.uniq!
   fw = open( @structureHandleFile, "w" )
   for i in 0..wList.size-1
      fw.puts wList[i]
   end
   fw.close
   checkStruct()
 end

 def checkStruct()
   stList = Array.new
   fr = open( @structureHandleFile, "r" )
   fr.each { |line|
     stList << (line.chomp).strip
   }
   fr.close
   for i in 0..stList.size-2
        il = stList[i].split(" ")
     for j in i+1..stList.size-1
        jl = stList[j].split(" ")
        if il[0] == jl[0] || il[1] == jl[1]
           puts "Error: structure"
           exit(0)
        end
     end
   end
 end

 def getCommitID( i )
   cf = @commitFileList[i]
   el = ""
   begin
     fr = open( cf, "r" )
     fr.each { |line|
       el = (line.chomp).strip
     }
     fr.close
   rescue
     el = nil
   end
   return el
 end
 def setCommitID( i, id )
   cf = @commitFileList[i]
   fw = open( cf, "w" )
   fw.puts id
   fw.close
 end

 def getHandleID( file )
   hList = Array.new
   fr = open( @itemHandleFile, "r" )
   fr.each { |line|
      hList << (line.chomp).strip
   }
   fr.close
   for i in 0..hList.size-1
     il = hList[i].split(" ")
     if il[0] == file
        return il[1]
     end
   end
 end

 def setHandleID( list )
  hList = Array.new
  fr = open( @itemHandleFile, "r" )
  fr.each { |line|
    hList << (line.chomp).strip
  }
  fr.close
  wList = hList + list
  wList.uniq!
  fw = open( @itemHandleFile, "w" )
  for i in 0..wList.size-1
    fw.puts wList[i]
  end
  fw.close
  checkItemHandle()
 end

 def checkItemHandle()
   hList = Array.new
   fr = open( @itemHandleFile, "r" )
   fr.each { |line|
     hList << (line.chomp).strip
   }
   fr.close
   for i in 0..hList.size-2
      il = hList[i].split(" ")
     for j in i+1..hList.size-1
       jl = hList[i].split(" ")
       if il[0] == jl[0] || il[1] == jl[1]
          puts "Error: item handle."
          exit(0)
       end
     end
   end
 end

=begin
 def getCommitID( repo )
   i = -1
   for j in 0..@repoList.size-1
     if @repoList[j] == repo
        i = j
     end
   end
   el = ""
   if i == -1
     return nil
   else
     cf = @repo[i] + "/" + $commit_log
     begin
       fr = open( cf, "r" )
       fr.each { |line|
         el = (line.chomp).strip
       }
       fr.close
     rescue
       el = nil
     end
   end
   return el
 end
=end

=begin
 def setCommitID( repo, id )
 end
=end


end
