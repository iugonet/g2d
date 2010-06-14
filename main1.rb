# -*- coding : utf-8 -*-
require 'fileutils'
require 'main1/Config'
require 'main1/Repository'
require 'main1/GitDSpace'

require 'main2/ActionState'
require 'main2/StructBuilder'
require 'main2/ItemImport'

GitCommand = "git"

pwd = Dir.pwd
conf = Config.new( pwd )
# read conf. get host and user name.
puts "Host: " + conf.getHost
puts "User: " + conf.getUser
# end conf. get host and user name.
# read repository path.
puts conf.getRepoList
# end read repository path.

gSpace = GitDSpace.new( pwd, conf.getRepoList )
gSpace.setCommandPath( GitCommand )
gSpace.gitPull
gSpace.init

repo = Repository.new( pwd, conf.getRepoList )
repo.setCommandPath( GitCommand )
repo.gitPull( conf.getHost, conf.getUser )
repo.gitCommitLog
repo.setGitDSpace( gSpace )
repo.getChangeList

aState = ActionState.new( pwd )
aState.sift
aState.test

sb = StructBuilder.new( pwd, repo.getWorkDir, gSpace )
sb.setFileList( aState.getAddList )
sb.import

ii = ItemImport.new( pwd, repo.getWorkDir, gSpace )
ii.setFileList( aState.getAddList )
ii.makeImport
ii.runImport
ii.setMapfile
