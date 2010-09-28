# -*- coding : utf-8 -*-

require 'fileutils'
require 'main1/Git'

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
     if !FileTest.exist?( cf )
       fr = open( cf, "w" )
       fr.close
     end
     @commitFileList << cf
   end
   hf = @repoDir + "/" + ItemHandle_log
   sf = @repoDir + "/" + StructureHandle_log
   if !FileTest.exist?( hf )
     fr = open( hf, "w" )
     fr.close
   end
   if !FileTest.exist?( sf )
     fr = open( sf, "w" )
     fr.close
   end
   @itemHandleFile = hf
   @structureHandleFile = sf
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

 def writeStruct( list )
   stList = getLineList( @structureHandleFile )
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
   stList = getLineList( @structureHandleFile )
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
   fw = open( @commitFileList[i], "w" )
   fw.puts id
   fw.close
 end

 def deleteHandleID2( file, id )
   hList = getLineList( @itemHandleFile )
   ii = -1
   for i in 0..hList.size-1
     il = hList[i].split(" ")
     if il[0] == file && il[1] == id
        ii = i
        break
     end
   end
   if ii != -1
     hList.delete_at(ii)
     puts "Delete Item: " + file
     fw = open( @itemHandleFile, "w" )
     for i in 0..hList.size-1
        fw.puts hList[i]
     end
     fw.close
   else
     puts "Error: delete item: " + file
     exit(0)
   end
 end

 def deleteHandleID( file )
   hList = getLineList( @itemHandleFile )
   ii = -1
   for i in 0..hList.size-1
     il = hList[i].split(" ")
     if il[0] == file
        ii = i
        break
     end
   end
   if ii != -1
     hList.delete_at(ii)
     puts "Delete Item: " + file
     fw = open( @itemHandleFile, "w" )
     for i in 0..hList.size-1
       fw.puts hList[i]
     end
     fw.close
   else
     puts "Error: delete item: " + file
     exit(0)
   end
 end

 def getHandleID( file )
   hList = getLineList( @itemHandleFile )
   for i in 0..hList.size-1
     il = hList[i].split(" ")
     puts il[0] + " : " + file
     if il[0] == file
        puts il[1]
        return il[1]
     end
   end
 end

 def setHandleID( list )
  hList = getLineList( @itemHandleFile )
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
   hList = getLineList( @itemHandleFile )
   for i in 0..hList.size-2
      il = hList[i].split(" ")
     for j in i+1..hList.size-1
       jl = hList[j].split(" ")
       if il[0] == jl[0] || il[1] == jl[1]
          puts "Error: item handle."
          puts il[0] + " : " + jl[0]
          puts il[1] + " : " + jl[1]
          exit
       end
     end
   end
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
