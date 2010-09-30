# -*- coding : utf-8 -*-

class Git

 GitCommand = "git"

 def initialize( user, host )
   @user = user
   @host = host
 end

 def getPullCommand()
   str = sprintf( "%s pull", GitCommand )
   return str
 end

 def getCloneCommand( project )
   str = sprintf( "%s clone ssh://%s@%s/~/git/%s",
                  GitCommand, @user, @host, project )
   return str
 end

 def getPushCommand( message="update" )
   str1 = sprintf( "%s add .", GitCommand )
   str2 = sprintf( "%s commit -am \"%s\"", GitCommand, message )
   str3 = sprintf( "%s push", GitCommand )
   return str1, str2, str3
 end

 def getLogCommand( outfilename )
   str = sprintf( "%s log | grep \"commit \" | grep -v \" commit\" > %s",
                  GitCommand, outfilename )
   return str
 end

 def getShowCommand( commitID, outfilename )
   str = sprintf( "%s show --pretty=oneline -p %s > %s",
                  GitCommand, commitID, outfilename )
   return str
 end

end
