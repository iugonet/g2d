# -*- coding : utf-8 -*-
require 'fileutils'
require 'main1/Config'
require 'main1/Repository'
require 'main1/GitDSpace'

require 'main2/FileStatus'
require 'main2/FileList'
require 'main2/StructBuilder'
require 'main2/ItemImport'
require 'main2/ItemReplace'
require 'main2/ItemDelete'

pwd = Dir.pwd
conf = Config.new( pwd )

gSpace = GitDSpace.new( pwd, conf.getRepoList )
gSpace.pull
gSpace.init

repo = Repository.new( pwd, conf.getRepoList )
repo.initGit( conf.getHost, conf.getUser )
repo.gitPull
repo.gitCommitLog
repo.setGitDSpace( gSpace )
repo.getChangeList


fileStatus = FileStatus.new( pwd )
fileStatus.readChangeLog
fileStatus.split
fileStatus.writeLog

addList = FileList.new( pwd, repo.getWorkDir )
addList.setRepositoryList( conf.getRepoDirList )
addList.setFileList( fileStatus.getAddList )


replaceList = FileList.new( pwd, repo.getWorkDir )
replaceList.setRepositoryList( conf.getRepoDirList )
replaceList.setFileList( fileStatus.getReplaceList )

deleteList = FileList.new( pwd, repo.getWorkDir )
deleteList.setRepositoryList( conf.getRepoDirList )
deleteList.setFileList( fileStatus.getDeleteList )

if deleteList.getSize > 0
  puts "Delete Item"
  item_delete = ItemDelete.new( pwd, repo.getWorkDir, gSpace )
  item_delete.setFileList( deleteList.getFileList )
  item_delete.make
  item_delete.run

  item_delete.checkDirectory()
  item_delete.runClean()
end

if addList.getSize > 0
  puts "Build Structure"
  structure = StructBuilder.new( pwd, repo.getWorkDir, gSpace )
  structure.setFileList( addList.getFileList )
  structure.build
end

if addList.getSize > 0
  puts "Import Item"
  item_import = ItemImport.new( pwd, repo.getWorkDir, gSpace )
  item_import.setFileList( addList.getFileList )
  item_import.make
  item_import.run
  item_import.setMapfile
end

if replaceList.getSize > 0
  puts "Replace Item"
  item_replace = ItemReplace.new( pwd, repo.getWorkDir, gSpace )
  item_replace.setFileList( replaceList.getFileList )
  item_replace.make
  item_replace.run
end

#gSpace.push
