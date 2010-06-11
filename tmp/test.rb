# -*- coding : utf-8 -*-

require 'fileutils'
require 'conf'
require 'test2'

serv_conf = "conf/server.conf"
repo_conf = "conf/repo.conf"
gitCommand = "git"
#gitCommand = "/usr/local/git-1.6.5.3/bin/git"

# change current directory
Dir.chdir( wd )
pwd = Dir.pwd
puts "change Dir: " + pwd
# end change current directory

# get git log file
repo = Array.new
for i in 0..repoWorkDirList.size-1
 repo << repoWorkDirList[i] + "/" + File.basename( repoList[i], ".git" )
end

for i in 0..repo.size-1
# puts repo[i]
 Dir.chdir( repo[i] )
 gcom = sprintf("%s log | grep commit > %s/%s.log", gitCommand, pwd, File.basename( repoList[i].gsub(/[\/]/,'_'), ".git" ) )
 system( gcom )
end
# end get git log file


# now repo
gdspace = GitDSpace.new(host,user,cwd)
gdspace.makeDir("gitlog")
gdspace.clone()
gdspace.readRepo()
gdspace.checkDir()
# end


for i in 0..repo.size-1
 fstr = pwd + "/" + File.basename( repoList[i].gsub(/[\/]/,'_'), ".git" ) + ".log"
 puts fstr
 fr = open( fstr, "r" )
 fr.each { |line|
  puts line
 }
 fr.close
end



