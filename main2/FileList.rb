# -*- coding : utf-8 -*-

require 'fileutils'

class Path
  def initialize( absolute, relative )
    @absolute = absolute
    @relative = relative
  end
  def getAbsolute
    return @absolute
  end
  def getRelative
    return @relative
  end
end

class FileList

 def initialize( pwd, workDir )
   @pwd = pwd
   @workDir = workDir
   @list = Array.new
 end

 def setType( type )
   @type = type
 end

 def setRepositoryList( repositoryList )
   @repositoryList = repositoryList
 end

 def setFileList( list )
   for i in 0..list.size-1
     filename = list[i]
     p = Path.new( filename, changeAbsoluteToRelative(filename) )
     @list << p
   end
 end

 def addFile( filename )
   p = Path.new( filename, changeAbsoluteToRelative(filename) )
   @list << p
 end

 def changeAbsoluteToRelative( absolutePath )
   relativePath = ""
   for i in 0..@repositoryList.size-1
     repository = @repositoryList[i]
     newRepositoryName = File.basename( repository, ".git" )
     repositoryDir     = File.dirname( repository )
     newRepositoryDir  = repositoryDir.gsub(/[\/]/,'_')
     repositoryAbsolutePath = @pwd + "/" + @workDir + "/" + newRepositoryDir + "/" + newRepositoryName
     if absolutePath.include?( repositoryAbsolutePath )
       sp = repositoryAbsolutePath.size+1
       ep = absolutePath.size-1
       relativePath = absolutePath.slice(sp,ep)
       break
     end
   end
   return relativePath
 end

 def getSize()
   return @list.size
 end

 def getFileList()
   return @list
 end

end
