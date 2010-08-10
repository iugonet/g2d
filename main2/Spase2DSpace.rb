# -*- coding : utf-8 -*-

require 'date'
require 'tempfile'
require 'fileutils'
require 'rexml/document'
include REXML

class Spase2DSpace

# Input
 ElemDelimiter      = "$"
 QualifierDelimiter = " "
 NoteDelimiter      = "#"

# Output
 QualifierSeparator = ""
 QualifierQuerySeparator = "/"

# Output Schema
 OutSchema = "iugonet"

# WorkingDir
 WorkDir = "ImportDir"

# for DSpace
 Dublin_core_filename = "dublin_core.xml"
 Contents_filename    = "contents"

 def initialize( pwd )
   @pwd = pwd
   @elementList   = Array.new
   @qualifierList = Array.new
   @noteList      = Array.new
   @qualifierQueryList = Array.new

   f = @pwd + "/" + "conf/spase2dspace.txt"
   readList( f )
   makeTypeList()
 end

=begin
 def makeImportDir( dir )
   wd = dir + "/" + $workDir
   if FileTest.exist?(wd)
     puts "rm -rf " + wd
     FileUtils.rm_rf( wd )
   end
   Dir.mkdir( wd )
   puts "mkdir: " + wd
 end
=end

 def readList( file )
   fr = open( file, "r" )
   fr.each { |line|
     sline = line.strip
     slen = sline.length
     if slen != 0
       if sline[0].chr != ElemDelimiter
         qnline = sline.split( NoteDelimiter )
         if qnline.length == 1
            @elementList << qnline[0].strip
            @qualifierList << nil
            @noteList << nil
            @qualifierQueryList << nil
         else
            @elementList << qnline[0].strip
            @qualifierList << nil
            @noteList << qnline[1].strip
            @qualifierQueryList << nil
         end
       else
         qline = sline.delete( ElemDelimiter )
         qnline = (qline.strip).split( NoteDelimiter )
         if qnline.length == 1
           @elementList << @elementList[@elementList.size-1]
           @qualifierList << (qnline[0].strip).tr(QualifierDelimiter,QualifierSeparator)
           @noteList << nil
           @qualifierQueryList << (qnline[0].strip).tr(QualifierDelimiter,QualifierQuerySeparator)
         else
           @elementList << @elementList[@elementList.size-1]
           @qualifierList << (qnline[0].strip).tr(QualifierDelimiter,QualifierSeparator)
           @noteList << qnline[1].strip
           @qualifierQueryList << (qnline[0].strip).tr(QualifierDelimiter,QualifierQuerySeparator)
         end
       end
     end
   }
   fr.close
 end

 def checkLength

   for i in 0..@elementList.size-1
     if @elementList[i] != nil
       len = @elementList[i].length
       if len > 64
         puts "Error: element length > 64 : ", len
       end
     end
   end
   for i in 0..@qualifierList.size-1
     if @qualifierList[i] != nil
       len = @qualifierList[i].length
       if len > 64
         puts "Error: qualifier length > 64 : ", len
       end
     end
   end

 end

 def makeTypeList
   @rTypeList = Array.new
   @rTypeList << "NumericalData"
   @rTypeList << "Catalog"
   @rTypeList << "DisplayData"
   @rTypeList << "Granule"
   @rTypeList << "Instrument"
   @rTypeList << "Repository"
   @rTypeList << "Observatory"
   @rTypeList << "Document"
   @rTypeList << "Annotation"
   @rTypeList << "Registry"
   @rTypeList << "Service"
   @rTypeList << "Person"
 end


 def trxml( tstr )
   if tstr.include?( "&amp;"  ) ||
      tstr.include?( "&lt;"   ) ||
      tstr.include?( "&gt;"   ) ||
      tstr.include?( "&quot;" ) ||
      tstr.include?( "&apos;" )
   else
      astr = tstr.gsub( /[&]/, '&amp;'  )
      lstr = astr.gsub( /[<]/, '&lt;'   )
      gstr = lstr.gsub( /[>]/, '&gt;'   )
      qstr = gstr.gsub( /["]/, '&quot;' )
      rstr = qstr.gsub( /[']/, '&apos;' )
   end
   return rstr
 end


 def getQueryList()
   @queryList = Array.new
   for i in 0..@elementList.size-1
      if @qualifierList[i] != nil
         @queryList << "Spase/" + @elementList[i] + "/" + @qualifierQueryList[i]
      else
         @queryList << nil
      end
   end
 end

 DCFormat1 = "   <dcvalue element=\"%s\" qualifier=\"none\">%s</dcvalue>\n"
 DCFormat2 = "   <dcvalue element=\"%s\" qualifier=\"%s\">%s</dcvalue>\n"
 RangeExtension = "RangeSearch"
 DateFormat = "%Y%m%d%H%M%S"
 def write( fw, element, qualifier, text )
   if qualifier == nil
     fw.printf( DCFormat1, element, text )
   else
     fw.printf( DCFormat2, element, qualifier, text )
   end
 end

 def writeDateTime( fw, element, qualifier, text )
   if qualifier == nil
   else
     qualifier = qualifier + QualifierSeparator + RangeExtension
   end

   begin
     t = DateTime.parse( text )
     st = t.strftime( DateFormat )
     write( fw, element, qualifier, st )
   rescue
     return -1
   end
   return 0
 end

 
 def writeLocationLatitude( fw, element, qualifier, text )
   if qualifier == nil
   else
     qualifier = qualifier + QualifierSeparator + RangeExtension
   end
   tf = text.to_f
   if -90.0 < tf && tf < 90.0
     ti = ((tf+90.0)*ShiftSpatialCoverage).to_i
     ts = sprintf( SpatialCoverageFormat, ti )
     write( fw, element, qualifier, ts )
   else
      return -1
   end
   return 0
 end
 def writeLocationLongitude( fw, element, qualifier, text )
   tf = text.to_f
   if tf >= 0.0
   else
      tf = tf + 360.0
   end
   ti = (tf*ShiftSpatialCoverage).to_i
   ts = sprintf( SpatialCoverageFormat, ti );
   qualifier1 = qualifier + QualifierSeparator + RangeExtension + "1"
   qualifier2 = qualifier + QualifierSeparator + RangeExtension + "2"
   write( fw, element, qualifier1, ts )
   write( fw, element, qualifier2, ts )
 end


 ShiftSpatialCoverage = 100000.0
 SpatialCoverageFormat = "%08d"
 def writeSpatialCoverageLatitude( fw, element, qualifier, text )
   if qualifier == nil
   else
     qualifier = qualifier + QualifierSeparator + RangeExtension
   end
   tf = text.to_f
   if -90.0 < tf && tf < 90.0
     ti = ((tf+90.0)*ShiftSpatialCoverage).to_i
     st = sprintf( SpatialCoverageFormat, ti )
     write( fw, element, qualifier, st )
   else
     return -1
   end
   return 0
 end
 def writeSpatialCoverageLongitude( fw, element, qualifier, text )
   if qualifier == nil
   else
     qualifier = qualifier + QualifierSeparator + RangeExtension
   end
   tf = text.to_f
   if -360.0 < tf && tf < 360.0
     ti = ((tf+360.0)*ShiftSpatialCoverage).to_i
     st = sprintf( SpatialCoverageFormat, ti )
     write( fw, element, qualifier, st )
     tfb = tf - 360.0
     if -360.0 < tfb && tfb < 360.0
       ti = ((tfb+360.0)*ShiftSpatialCoverage).to_i
       st = sprintf( SpatialCoverageFormat, ti )
       write( fw, element, qualifier, st )
     end
     tff = tf + 360.0
     if -360.0 < tff && tff < 360.0
       ti = ((tff+360.0)*ShiftSpatialCoverage).to_i
       st = sprintf( SpatialCoverageFormat, ti )
       write( fw, element, qualifier, st )
     end
   else
     return -1
   end
   return 0
 end

 def setSpatialCoverageWesternmostLongitude( element, qualifier, text )
    @wl_element = element
    @wl_qualifier = qualifier
    @wl_text = text
    @wl = true
 end
 def setSpatialCoverageEasternmostLongitude( element, qualifier, text )
    @el_element = element
    @el_qualifier = qualifier
    @el_text = text
    @el = true
 end

 def setSpatialCoverageLongitude( fw )
   wl = @wl_text.to_f
   el = @el_text.to_f

   if wl > el
     puts "Error: Westernmost Longitude > Easternmost Longitude"
     puts "Westernmost: " + wl
     puts "Easternmost: " + el
     exit
   end

   if wl >= -360.0 && wl <= 360.0
   else
     puts "Error: wl = "  + wl
   end
   if el >= -360.0 && el <= 360.0
   else
     puts "Error: el = " + el
   end

   if wl >= 0.0 && el >= 0.0
   else
     wl = wl + 360.0
     el = el + 360.0
   end

   if wl >= 0.0 && wl <= 360.0 &&
      el >= 0.0 && el <= 360.0
     qualifier = @wl_qualifier + RangeExtension + "1"
     wi = (wl * ShiftSpatialCoverage).to_i
     ws = sprintf( SpatialCoverageFormat, wi )
     write( fw, @wl_element, qualifier, ws )
     qualifier = @el_qualifier + RangeExtension + "1"
     ei = (el * ShiftSpatialCoverage).to_i
     es = sprintf( SpatialCoverageFormat, ei )
     write( fw, @el_element, qualifier, es )
   end

   if wl >= 0.0   && wl <= 360.0 &&
      el >= 360.0 && el <= 720.0
     qualifier = @wl_qualifier + RangeExtension + "1"
     wi = (wl * ShiftSpatialCoverage).to_i
     ws = sprintf( SpatialCoverageFormat, wi )
     write( fw, @wl_element, qualifier, ws )
     qualifier = @el_qualifier + RangeExtension + "1"
     ei = (360.0 * ShiftSpatialCoverage).to_i
     es = sprintf( SpatialCoverageFormat, ei )
     write( fw, @el_element, qualifier, es )

     qualifier = @wl_qualifier + RangeExtension + "2"
     wi = (0.0 * ShiftSpatialCoverage).to_i
     ws = sprintf( SpatialCoverageFormat, wi )
     write( fw, @wl_element, qualifier, ws )
     qualifier = @el_qualifier + RangeExtension + "2"
     ei = ((el-360.0) * ShiftSpatialCoverage).to_i
     es = sprintf( SpatialCoverageFormat, ei )
     write( fw, @el_element, qualifier, es )
   end
   @wl = false
   @el = false
 end

 def conv( filename, mdir )

   resourcetype = ""
   fr = open( filename, "r" )
   doc = REXML::Document.new fr
   for i in 0..@rTypeList.size-1
     q = "Spase/"+@rTypeList[i]
     doc.elements.each(q){|data|
        if data != nil
           resourcetype = @rTypeList[i]
           break
        end
     }
   end
   fr.close

   f = mdir + "/" + "dublin_core.xml"
   fw = open( f, "w")
   fw.puts "<dublin_core schema=\"" + OutSchema + "\">"
   fn = File.basename( filename )
   write( fw, "filename", nil, fn )

   resourceid = ""
   fr = open( filename, "r" )
   doc = REXML::Document.new fr
   q = "Spase/"+resourcetype+"/ResourceID"
   doc.elements.each(q){|data|
     resourceid = data.text
   }
   write( fw, "ResourceID", nil, resourceid )
   write( fw, "ResourceType", nil, resourcetype )


   for i in 0..@queryList.size-1
     if @queryList[i] != nil
       doc.elements.each(@queryList[i]){|data|
       if data.text != nil
         write( fw, @elementList[i], @qualifierList[i], trxml(data.text) )
         if @qualifierList[i].include?("StartDate") ||
            @qualifierList[i].include?("StopDate")
           res = writeDateTime( fw, @elementList[i], @qualifierList[i], trxml(data.text) )
         elsif @qualifierList[i].include?("LocationLatitude")
           writeLocationLatitude( fw, @elementList[i], @qualifierList[i], trxml(data.text) )
         elsif @qualifierList[i].include?("LocationLongitude")
           writeLocationLongitude( fw, @elementList[i], @qualifierList[i], trxml(data.text) )
         elsif @qualifierList[i].include?("NorthernmostLatitude") ||
                 @qualifierList[i].include?("SouthernmostLatitude")
           res = writeSpatialCoverageLatitude( fw, @elementList[i], @qualifierList[i], trxml(data.text) )
         elsif @qualifierList[i].include?("WesternmostLongitude") ||
               @qualifierList[i].include?("EasternmostLongitude")
            if @qualifierList[i].include?("WesternmostLongitude")
              setSpatialCoverageWesternmostLongitude( @elementList[i], @qualifierList[i], trxml(data.text) )
            elsif @qualifierList[i].include?("EasternmostLongitude")
              setSpatialCoverageEasternmostLongitude( @elementList[i], @qualifierList[i], trxml(data.text) )
            end
            if @wl && @el
              setSpatialCoverageLongitude( fw )
            end
         end
       end
       }
     end
   end
   fw.puts "</dublin_core>"
   fw.close
   fr.close
   
 end

end
