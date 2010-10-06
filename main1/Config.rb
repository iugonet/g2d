# -*- coding : utf-8 -*-

class Config
 SERVER_CONF = "conf/serv.conf"
 REPOSITORY_CONF = "conf/repo.conf"

 def initialize( pwd )
  @pwd = pwd

  fr = open( SERVER_CONF, "r" )
  fr.each { |line|
    lt = (line.chomp).split(/=/)
    if lt.size == 2
      if lt[0].strip == "HOST"
        @host = lt[1].strip
      elsif lt[0].strip == "USER"
        @user = lt[1].strip
      end
    end
  }
  fr.close

  @repoList = Array.new
  fr = open( REPOSITORY_CONF, "r" )
  fr.each { |line|
    if  (line.chomp).strip != "" &&
        !line.include?("#")
      @repoList << (line.chomp).strip
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

 def getRepoDirList
   return @repoDirList
 end

end
