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
  fr = open( Repo_conf, "r" )
  fr.each { |line|
    if line.strip != ""
      if !line.include?("#")
        @repoList << (line.chomp).strip
      end
    end
  }
  fr.close

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

end
