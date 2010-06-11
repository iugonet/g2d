# -*- coding : utf-8 -*-

require 'fileutils'

class GitDSpace

 $repo_conf = "conf/repo.conf"
# $history_file = "history.log"

 def initialize( host, user, cwd )
   @host = host
   @user = user
   @cwd = cwd
   puts @host
   puts @user
   puts @cwd
 end

 def makeDir( dir )
   @wd = @cwd+"/"+dir
   if FileTest.exist?(@wd)
     if FileTest.directory?(@wd)
       puts "git dspace dir: " + @wd
     else
       puts "Error: " + @wd + " file exists"
       exit
     end
   else
     Dir.mkdir( @wd )
     puts "mkdir: " + @wd
   end
 end

 def clone()
   @cloneDir = @wd+"/dspace"
   if FileTest.exist?( @cloneDir )
     if FileTest.directory?( @cloneDir )
        Dir.chdir( @cloneDir )
        system("git pull");
     else
        exit
     end
   else
     Dir.chdir( @wd )
     system("git clone ssh://git@iugonet1.stelab.nagoya-u.ac.jp/~/git/dspace.git")
   end
 end

=begin
 def readRepo()
  @repoList = Array.new
  file = @cwd+"/"+$repo_conf
  puts file
  fr = open( file, "r" )
  fr.each { |line|
    if !line.include?("#")
      @repoList << line.chomp
    end
  }
  fr.close
 end

 def checkDir()
  @repoDirList = Array.new
  for i in 0..@repoList.size-1
   d = @repoList[i].split(/\//)
   str = @cloneDir + "/" + d[0]
   for j in 1..d.size-2
    str = str + "_" + d[j]
   end
   puts str
   @repoDirList << str
  end

  for i in 0..@repoDirList.size-1
    if FileTest.exist?( @repoDirList[i] )
      if FileTest.directory?( @repoDirList[i] )
      else
        puts "Error: " + @repoDirList[i] + " file exists"
        exit
      end
    else
      Dir.mkdir( @repoDirList[i] )
    end
  end

 end
=end

 def log( file )
  lfile = dir+"/"
  res = ""
  if FileTest.exist?( file )
   fr = open( file, "r" )
   fr.each { |line|
     res = line
   }
   fr.close
  else
  end
  return res
 end

 def log( file, commit  )
  file = dir+"/"+$history_file
  puts "history file: " + file
  fw = open( file, "a" )
  fw.puts commit
  fw.close
 end


end



