# -*- coding : utf-8 -*-

require 'fileutils'

require 'main1/Git'
require 'main1/HandleIDList'

class GitDSpace

 Git_conf            = "conf/gitdspace.conf"
 Commit_log          = "_Commit.log"
 StructureHandle_log = "StructureHandle.log"
 ItemHandle_log      = "ItemHandle.log"

 GitDirectory = "GitDSpace"

 def initialize( pwd, repoList )
   @pwd = pwd
   @repoList = repoList

   makeGitDir()
   readConf()
   @git = Git.new( @user, @host )
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
     if lt.size == 2
       if lt[0].strip == "HOST"
         @host = lt[1].strip
       elsif lt[0].strip == "USER"
         @user = lt[1].strip
       elsif lt[0].strip == "REPO"
         @repoPath = lt[1].strip
       end
     end
   }
   fr.close
 end

 def gitPull
   dir = File.basename( @repoPath, ".git" )
   @repoDir = @gwd+"/"+dir
   if FileTest.exist?( @repoDir )
     Dir.chdir( @repoDir )
     system( @git.getPullCommand() )
   else
     Dir.chdir( @gwd )
     system( @git.getCloneCommand( @repoPath ) )
   end
   Dir.chdir( @pwd )
 end

 def init
   @commitFileList = Array.new
   for i in 0..@repoList.size-1
     f = @repoList[i].gsub(/[\/]/,'_')
     b = File.basename( f, ".git" )
     cf = @repoDir + "/" + b + Commit_log
     initFile( cf )
     @commitFileList << cf
   end
   hf = @repoDir + "/" + ItemHandle_log
   sf = @repoDir + "/" + StructureHandle_log
   initFile( hf )
   initFile( sf )
   @itemHandleFile = hf
   @structureHandleFile = sf
 end

 def initFile( filename )
   if !FileTest.exist?( filename )
     fr = open( filename, "w" )
     fr.close
   end
 end

 def gitPush( message )
   com1, com2, com3 = @git.getPushCommand( message )
   Dir.chdir( @repoDir )
   system( com1 )
   system( com2 )
   system( com3 )
   Dir.chdir( @pwd )
 end

 def readStruct()
   stList = getLineList( @structureHandleFile )
   return stList
 end

 def writeStruct( addList )
   hid = HandleIDList.new( @structureHandleFile )
   hid.add( addList )
   hid.write
   hid.checkOverlap
 end

 def getCommitID( i )
   filename = @commitFileList[i]
   el = ""
   begin
     fr = open( filename, "r" )
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
   fw = open( @commitFileList[i], "w" )
   fw.puts id
   fw.close
 end

 def deleteHandleID2( file, id )
   hid = HandleIDList.new( @itemHandleFile )
   hid.deleteID( id )
   hid.write
 end

 def deleteHandleID( file )
   hid = HandleIDList.new( @itemHandleFile )
   hid.deleteFile( file )
   hid.write
 end

 def getHandleID( file )
   hList = getLineList( @itemHandleFile )
   for i in 0..hList.size-1
     il = hList[i].split(" ")
     if il[0] == file
        return il[1]
     end
   end
 end

 def setHandleID( addList )
   hid = HandleIDList.new( @itemHandleFile )
   hid.add( addList )
   hid.write
   hid.checkOverlap
 end

 def getLineList( filename )
   lineList = Array.new
   fr = open( filename, "r" )
   fr.each { |line|
     lineList << (line.chomp).strip
   }
   fr.close
   return lineList
 end

end
