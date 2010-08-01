# -*- coding : utf-8 -*-

class DSpaceType

# Input
 ElemDelimiter      = "$"
 QualifierDelimiter = " "
 NoteDelimiter      = "#"

# Output
 QualifierSeparator = ""

 RangeExtension = "RangeSearch"

# Output Schema
 OutSchema = "iugonet"
 OutNamespace = "http://www.iugonet.org/"

# input filename
 InFilename = "dublin-core-types.xml"
# output filename
 OutFilename = "spase-types.xml"

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
       if sline[0].chr != ElemDelimiter
         qnline = sline.split( NoteDelimiter )
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
         qline = sline.delete( ElemDelimiter )
         qnline = (qline.strip).split( NoteDelimiter )
         if qnline.length == 1
           @elementList << @elementList[@elementList.size-1]
           @qualifierList << (qnline[0].strip).tr(QualifierDelimiter,QualifierSeparator)
           @noteList << nil
         else
           @elementList << @elementList[@elementList.size-1]
           @qualifierList << (qnline[0].strip).tr(QualifierDelimiter,QualifierSeparator)
           @noteList << qnline[1].strip
         end
       end
     end
   }
   fr.close
 end

 def writeSchema( fw, schema, namespace )
    fw.puts   "  <dc-schema>"
    fw.printf("    <name>%s</name>\n", schema )
    fw.printf("    <namespace>%s</namespace>\n", namespace )
    fw.puts   "  </dc-schema>"
    fw.puts ""
 end

 def writeType( fw, schema, element, qualifier, note )
    if element.size > 64
       puts "Error: element.size > 64 : " + element
       exit
    end
    if qualifier != nil && qualifier.size > 64
       puts "Error: qualifier.size > 64 : " + qualifier
       exit
    end
    fw.puts     "  <dc-type>"
    fw.printf(  "    <schema>%s</schema>\n", schema )
    fw.printf(  "    <element>%s</element>\n", element )
    if qualifier != nil
      fw.printf("    <qualifier>%s</qualifier>\n", qualifier )
    end
    if note != nil
      fw.printf("    <scope_note>%s</scope_note>\n", note )
    end
    fw.puts     "  </dc-type>"
    fw.puts ""
 end

 def writeTypeDateTime( fw, schema, element, qualifier, note )
   if qualifier.include?("StartDate") ||
      qualifier.include?("StopDate")
     qualifier = qualifier + QualifierSeparator + RangeExtension
   end
   writeType( fw, schema, element, qualifier, note )
 end

 def writeTypeSpatialCoverage( fw, schema, element, qualifier, note )
    if qualifier.include?("NorthernmostLatitude") ||
       qualifier.include?("SouthernmostLatitude")
      qualifier = qualifier + QualifierSeparator + RangeExtension
      writeType( fw, schema, element, qualifier, note )
    elsif qualifier.include?("WesternmostLongitude") ||
          qualifier.include?("EasternmostLongitude")
      qualifier1 = qualifier + QualifierSeparator + RangeExtension + "1"
      writeType( fw, schema, element, qualifier1, note )
      qualifier2 = qualifier + QualifierSeparator + RangeExtension + "2"
      writeType( fw, schema, element, qualifier2, note )
    end
 end

 def test()

   fw = open( OutFilename, "w" )

     fr = open( InFilename, "r" )
     fr.each { |line|
       if line.include?("</dspace-dc-types>") == false
         fw.puts line
       end
     }
     fr.close

   writeSchema( fw, OutSchema, OutNamespace )

   for i in 0..@elementList.size-1
      writeType( fw, OutSchema, @elementList[i], @qualifierList[i], @noteList[i] )
      if @qualifierList[i] != nil &&
        ( @qualifierList[i].include?("StartDate") ||
          @qualifierList[i].include?("StopDate") )
         writeTypeDateTime( fw, OutSchema, @elementList[i], @qualifierList[i], @noteList[i] )
      elsif @qualifierList[i] != nil &&
           ( @qualifierList[i].include?("NorthernmostLatitude") ||
             @qualifierList[i].include?("SouthernmostLatitude") ||
             @qualifierList[i].include?("EasternmostLongitude") ||
             @qualifierList[i].include?("WesternmostLongitude") )
         writeTypeSpatialCoverage( fw, OutSchema, @elementList[i], @qualifierList[i], @noteList[i]  )
      end
   end

   writeType( fw, OutSchema, "filename",     nil, nil )
   writeType( fw, OutSchema, "ResourceID",   nil, nil )
   writeType( fw, OutSchema, "ResourceType", nil, nil )

   fw.puts "</dspace-dc-types>"
   fw.close

   puts "write: spase-types.xml"
 end
end

dt = DSpaceType.new
dt.test
