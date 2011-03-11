# -*- coding : utf-8 -*-

require 'fileutils'
require 'date'

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

 def pull
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

 def push
   t = DateTime.now
   message = "Update: " + t.to_s
   com1, com2, com3 = @git.getPushCommand( message )
   Dir.chdir( @repoDir )
   system( com1 )
   system( com2 )
   system( com3 )
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

 def getItemHandleFile
   return @itemHandleFile
 end
 def getStructureHandleFile
   return @structureHandleFile
 end

 def initFile( filename )
   if !FileTest.exist?( filename )
     fr = open( filename, "w" )
     fr.close
   end
 end

 def readStruct()
   stList = getLineList( @structureHandleFile )
   return stList
 end

 def writeStruct( addList )
   if addList != nil && addList.size > 0
     hid = HandleIDList.new( @structureHandleFile )
     hid.add( addList )
     hid.write
     hid.checkOverlap
   end
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
   if addList != nil && addList.size > 0
     hid = HandleIDList.new( @itemHandleFile )
     hid.add( addList )
     hid.write
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

 def getDeleteStructureList( deleteDirList )
   deleteList = Array.new
   hList = getLineList( @itemHandleFile )
   for i in 0..deleteDirList.size-1
     del = true
     for j in 0..hList.size-1
       if hList[j].include?(deleteDirList[i])
         del = false
         break
       end
     end
     if del
       deleteList << deleteDirList[i]
     end
   end
   return deleteList
 end

 def deleteCollection( dir )

   hList = getLineList( @structureHandleFile )

   collection_id = ""
   for i in 0..hList.size-1
      la = hList[i].split(" ")
      if la[0] == dir && la[2] == "col"
        collection_id = la[1]
        break
      end
   end

   parent_id = ""
   if collection_id.size > 0
     parent = File.dirname( dir )
     for i in 0..hList.size-1
       la = hList[i].split(" ")
       if la[0] == parent && la[2] == "com"
         parent_id = la[1]
         break
       end
     end
   end

   if parent_id.size > 0 || collection_id.size > 0
     if parent_id.size > 0 && collection_id.size > 0
     else
       puts "Error: " + pa
       exit
     end
   end

   return parent_id, collection_id
 end

 def deleteCommunity( dir )
   hList = getLineList( @structureHandleFile )

   community_id = ""
   child = false
   for i in 0..hList.size-1
     la = hList[i].split(" ")
     if la[0].include?( dir ) && la[0].size > dir.size
       child = true
       break
     else
       if la[0] == dir && la[2] == "com"
         community_id = la[1]
       end
     end
   end

   if child
     community_id = ""
   end

   return community_id
 end

 def deleteStructure( dir )

   community_id, collection_id = deleteCollection( dir )

   if community_id.size > 0 && collection_id.size > 0
     puts "delete: " + community_id + " " + collection_id
     deleteStructureID( collection_id )
     return community_id, collection_id
   end

   community_id = deleteCommunity( dir )
   if community_id.size > 0
     deleteStructureID( community_id )
     return community_id, ""
   end
   return "", ""
 end

 def deleteStructureID( handleID )
   hList = getLineList( @structureHandleFile )
   for i in 0..hList.size-1
     la = hList[i].split(" ")
     if la[1] == handleID
       puts "Delete: " + hList[i]
       hList.delete_at(i)
       break
     end
   end

   fw = open( @structureHandleFile, "w" )
   for i in 0..hList.size-1
     fw.puts hList[i]
   end
   fw.close
   
 end

end
