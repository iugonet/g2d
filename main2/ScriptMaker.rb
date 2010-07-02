# -*- coding : utf-8

class ScriptMaker

 def initialize( filename )
   @fw = open( filename, "w" )
   @fw.puts "#!/bin/bash"
   @fw.puts ""
 end

 def puts( str )
   @fw.puts str
 end

 def finalize()
   @fw.close
 end

end
