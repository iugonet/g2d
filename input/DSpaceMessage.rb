# -*- coding : utf-8 -*-

class DSpaceType

# Input
 $elemDelimiter      = "$"
 $qualifierDelimiter = " "
 $noteDelimiter      = "#"

# Output
 $qualifierSeparator = ""

# Output Schema
 $outSchema = "iugonet"

# output filename
 $outFilename = "message.properties"

 def initialize
   @elementList = Array.new
   @qualifierList = Array.new
   @noteList = Array.new

   readList( "../conf/spase2dspace.txt" )
 end

 def readList( file )
   fr = open( file, "r" )
   fr.each { |line|
     puts line
     sline = line.strip
     slen = sline.length
     if slen != 0
       if sline[0].chr != $elemDelimiter
         qnline = sline.split( $noteDelimiter )
         if qnline.length == 1
            @elementList << qnline[0].strip
            @qualifierList << nil
            @noteList << nil
         else
            @elementList << qnline[0].strip
            @qualifierList << nil
            @noteList << nil
         end
       else
         qline = sline.delete( $elemDelimiter )
         qnline = (qline.strip).split( $noteDelimiter )
         if qnline.length == 1
           @elementList << @elementList[@elementList.size-1]
           @noteList << qnline[0].strip
           @qualifierList << (qnline[0].strip).tr($qualifierDelimiter,$qualifierSeparator)
         else
           @elementList << @elementList[@elementList.size-1]
           @noteList << qnline[0].strip
           @qualifierList << (qnline[0].strip).tr($qualifierDelimiter,$qualifierSeparator)
         end
       end
     end
   }
   fr.close
 end

 def writeValue( fw, schema, element, qualifier, qualifier1 )
   if qualifier != nil
     fw.printf("metadata.%s.%s.%s = %s\n", schema, element, qualifier, qualifier1 )
   else
     fw.printf("metadata.%s.%s = %s\n",    schema, element, element )
   end
 end

 def test()
   fw = open( $outFilename, "w" )
   fw.printf("metadata.%s.%s = %s\n", $outSchema, "ResourceType", "Resource Type" )
   fw.printf("metadata.%s.%s = %s\n", $outSchema, "ResourceID", "Resource ID" )
   for i in 0..@elementList.size-1
      writeValue( fw, $outSchema, @elementList[i], @qualifierList[i], @noteList[i] )
   end
   fw.printf("metadata.%s.%s = %s\n", $outSchema, "Filename", "Filename" )
   fw.close

   puts "write: message.properties"
 end
end

dt = DSpaceType.new
dt.test
