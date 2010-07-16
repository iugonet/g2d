# -*- coding : utf-8 -*-

class Config
 Serv_conf = "conf/serv.conf"
 Repo_conf = "conf/repo.conf"

 def initialize( pwd )
  @pwd = pwd

  fr = open( Serv_conf, "r" )
  fr.each { |line|
    lt = (line.chomp).split(/=/)
    if lt[0].strip == "HOST"
      @host = lt[1].strip
    elsif lt[0].strip == "USER"
      @user = lt[1].strip
    end
  }
  fr.close

  @repoList = Array.new
  @topList  = Array.new
  fr = open( Repo_conf, "r" )
  fr.each { |line|
    if  line.strip != "" &&
       !line.include?("#")
      lt = (line.chomp).split(/ /)
        @repoList << (lt[0]).strip
        if lt[1] != nil
          @topList  << (lt[1]).strip
        else
          @topList  << nil
        end
    end
  }
  fr.close

  @repoDirList = Array.new
  for i in 0..@repoList.size-1
     str = File.dirname(@repoList[i]) + "/" + File.basename(@repoList[i],".git")
     @repoDirList << str
  end

 end

 def getHost
   return @host
 end

 def getUser
   return @user
 end

 def getRepoList
   return @repoList
 end
 def getTopList
   return @topList
 end

 def getRepoDirList
   return @repoDirList
 end

end
