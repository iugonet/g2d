# -*- coding : utf-8 -*-

class DSpaceType

# Input
 $elemDelimiter      = "$"
 $qualifierDelimiter = " "
 $noteDelimiter      = "#"

# Output
 $qualifierSeparator = ""

 $rangeExtension = "RangeSearch"

# Output Schema
 $outSchema = "iugonet"

# output filename
 $outFilename = "itemdisplay.conf"

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
            @noteList << qnline[1].strip
         end
       else
         qline = sline.delete( $elemDelimiter )
         qnline = (qline.strip).split( $noteDelimiter )
         if qnline.length == 1
           @elementList << @elementList[@elementList.size-1]
           @qualifierList << (qnline[0].strip).tr($qualifierDelimiter,$qualifierSeparator)
           @noteList << nil
         else
           @elementList << @elementList[@elementList.size-1]
           @qualifierList << (qnline[0].strip).tr($qualifierDelimiter,$qualifierSeparator)
           @noteList << qnline[1].strip
         end
       end
     end
   }
   fr.close
 end

 def writeValue( fw, schema, element, qualifier )
   if element.size > 64
     puts "Error: element.size > 64: " + element
     exit
   end
   if qualifier != nil && qualifier.size > 64
     puts "Error: qualifier.size > 64: " + qualifier
     exit
   end
   if qualifier != nil
     if qualifier.include?("URL")
       fw.printf("%s.%s.%s(link), \\\n", schema, element, qualifier )
     else
       fw.printf("%s.%s.%s, \\\n", schema, element, qualifier )
     end
   else
     fw.printf("%s.%s, \\\n",    schema, element )
   end
 end

 def test()
   fw = open( $outFilename, "w" )
   fw.puts "webui.itemdisplay.default = \\"
   fw.printf("%s.%s, \\\n", $outSchema, "ResourceType" )
   for i in 0..@elementList.size-1
      writeValue( fw, $outSchema, @elementList[i], @qualifierList[i] )
   end
   fw.printf("%s.%s\n", $outSchema, "Filename" )
   fw.close

   puts "write: itemdisplay.conf"
 end
end

dt = DSpaceType.new
dt.test
