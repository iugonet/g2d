# -*- coding : utf-8 -*-
require 'fileutils'
require 'main1/Config'
require 'main1/Repository'
require 'main1/GitDSpace'

require 'main2/ActionState'
require 'main2/StructBuilder'
require 'main2/ItemImport'
require 'main2/ItemReplace'
require 'main2/ItemDelete'

pwd = Dir.pwd
conf = Config.new( pwd )

gSpace = GitDSpace.new( pwd, conf.getRepoList )
gSpace.gitPull
gSpace.init

repo = Repository.new( pwd, conf.getRepoList )
repo.initGit( conf.getHost, conf.getUser )
repo.gitPull
repo.gitCommitLog
repo.setGitDSpace( gSpace )
repo.getChangeList

aState = ActionState.new( pwd )
aState.sift
aState.test

structure = StructBuilder.new( pwd, repo.getWorkDir, gSpace )
structure.setRepoDirList( conf.getRepoDirList )
structure.setFileList( aState.getAddList )
structure.build

item_import = ItemImport.new( pwd, repo.getWorkDir, gSpace )
item_import.setFileList( aState.getAddList )
item_import.setRepoDirList( conf.getRepoDirList )
item_import.make
item_import.run
item_import.setMapfile

item_replace = ItemReplace.new( pwd, repo.getWorkDir, gSpace )
item_replace.setFileList( aState.getReplaceList )
item_replace.setRepoDirList( conf.getRepoDirList )
item_replace.make
item_replace.run

item_delete = ItemDelete.new( pwd, repo.getWorkDir, gSpace )
item_delete.setFileList( aState.getDeleteList )
item_delete.setRepoDirList( conf.getRepoDirList )
item_delete.make
item_delete.run
item_delete.updateMapfile
