# -*- coding : utf-8 -*-

require 'fileutils'
require 'ActionState'
require 'StructBuilder'
require 'ItemImporter'

$flist = "WorkingDir/a.log"


sb = StructBuilder.new( Dir.pwd )
sb.setFileList( aState.getAddList )
sb.test

ii = ItemImporter.new( Dir.pwd )
ii.setFileList( aState.getAddList,
                aState.getReplaceList,
                aState.getDeleteList )
ii.test
=begin
ii.runImport
ii.setMapfile

ir = ItemReplacer.new

id = ItemDeleter.new

=end
