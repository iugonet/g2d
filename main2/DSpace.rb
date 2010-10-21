class DSpace

  def initialize( pwd )
     @pwd = pwd

     f = @pwd + "/conf/dspace.conf"
     fr = open( f, "r" )
     fr.each { |line|
       lt = (line.chomp).split(/=/)
       if lt.size == 2
         if lt[0].strip == "DIR"
           @idir = lt[1].strip
         elsif lt[0].strip == "EMAIL"
           @email = lt[1].strip
         end
       end
     }
     fr.close


     @import_path = @idir + "/bin/import"
     @structurebuilder_path = @idir + "/bin/structure-builder"

  end

  def getStructureBuilderCommand( input_xml, output_xml, handle_id, type )
    str = sprintf( "%s -e %s -f %s -o %s -h %s -t %s",
                   @structurebuilder_path, @email,
                   input_xml, output_xml, handle_id, type )
    return str
  end

  def getImportCommand( handle_id, source_dir, mapfile )
    str = sprintf( "%s -a -e %s -c %s -s %s -m %s",
                   @import_path, @email,
                   handle_id, source_dir, mapfile )
    return str
  end
  def getReplaceCommand( handle_id, source_dir, mapfile )
    str = sprintf( "%s -r -e %s -c %s -s %s -m %s",
                   @import_path, @email,
                   handle_id, source_dir, mapfile )
    return str
  end
  def getDeleteCommand( mapfile )
    str = sprintf( "%s -d -e %s -m %s",
                   @import_path, @email, mapfile )
    return str
  end

  def getDeleteCollectionCommand( community_handle_id,
                                  delete_collection_handle_id )
    str = sprintf( "%s -e %s -f dummyfile_in -o dummyfile_out -h %s -d %s",
                   @structurebuilder_path, @email,
                   community_handle_id, delete_collection_handle_id )
    return str
  end

  def getDeleteCommunityCommand( delete_community_handle_id )
    str = sprintf( "%s -e %s -f dummyfile_in -o dummyfile_out -d %s",
                   @structurebuilder_path, @email,
                   delete_community_handle_id)
  end

end
