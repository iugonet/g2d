#!/bin/bash

#### Mod by STEL, N.UMEMURA, 20121016

#### [START] Define ###################################################################

#### Variable Parameters ####
# Archive Flag
ARCHIVEFLAG=0           # 0:Yes, 1:No
# Archive Mode
ARCHIVEMODE=1           # 0:raw, 1:compress(tar.gz)
# Number to Archives
ARCHIVEMAX=5            # ARCHIVEMAX > 0

# Files and Directories to Archive
# [Note] Place to Save:
# - G2DFILES1               --> $ARCHIVEDIR and $ADIR
# - G2DFILES2 and G2DFILES3 --> $ARCHIVEDIR
# - G2DDIRS                 --> $ARCHIVEDIR
G2DFILES1=("i.out" "r.out" "time.out" "skip.out" "Change.log" "FileStatus.log")
G2DFILES2=("Change.log" "FileStatus.log" "runImport.sh" "runReplace.sh" "runDelete.sh")
G2DFILES3=("WorkDir/Metadata_IUGONET_Commit.log" "WorkDir/Metadata_IUGONET_Granule_Commit.log")
G2DDIRS=("GitDSpace")

# Datastore Layer to Archive
LUCENEDIR='/opt/dspace/search'
DBNAME='dspace'

#### Invariable Parameters ####
CURRENTDATE=`date '+%Y%m%d.%H%M%S'`
ADIR='log'
ARCDIR=${ADIR}'/archive'
ARCHIVEDIR=${ARCDIR}'/'${CURRENTDATE}


#### [START] Exec #####################################################################

#### Debug
echo '>>> START: clean.sh --------------------------------'


#### Judge
if [ ${ARCHIVEFLAG} = 0 ]; then


  #### Debug
  echo '###INFO> OK! Exec Archive!'


  #### [Step.0] Create Directory ####
  mkdir -p ${ARCHIVEDIR}
  echo '###INFO> Archive Directory ----> ['${ARCHIVEDIR}']'


  #### [Step.1] Archive g2d ####
  ## Debug
  echo '###INFO> Archive g2d, START.'
  ## Archive: (Files-1)
  mkdir -p ${ARCHIVEDIR}/g2d
  for file in ${G2DFILES1[@]}; do
    if [ -r ${file} ]; then
      cp -p ${file} ${ARCHIVEDIR}/g2d/.
      cp -p ${file} ${ADIR}/${file}.${CURRENTDATE}
#     echo 'cp -p '${file} ${ARCHIVEDIR}'/g2d/.'
    fi
  done
  ## Archive: (Files-2)
# mkdir -p ${ARCHIVEDIR}/g2d
  for file in ${G2DFILES2[@]}; do
    if [ -r ${file} ]; then
      cp -p ${file} ${ARCHIVEDIR}/g2d/.
#     echo 'cp -p '${file} ${ARCHIVEDIR}'/g2d/.'
    fi
  done
  ## Archive: (Files-3)
  mkdir -p ${ARCHIVEDIR}/g2d/WorkDir
  for file in ${G2DFILES3[@]}; do
    if [ -r ${file} ]; then
      cp -p ${file} ${ARCHIVEDIR}/g2d/WorkDir/.
#     echo 'cp -p '${file} ${ARCHIVEDIR}'/g2d/WorkDir/.'
    fi
  done
  ## Archive: (Directory)
  for dir in ${G2DDIRS[@]}; do
    if [ -d ${dir} ]; then
      cp -pr ${dir} ${ARCHIVEDIR}/g2d/.
#     echo 'cp -pr '${dir} ${ARCHIVEDIR}'/g2d/.'
    fi
  done
  ## Debug
  echo '###INFO> Archive g2d, FINISHED.'


  #### [Step.2] Archive Metadata Files ####
  # pass


  #### [Step.3] Archive Lucene ####
  ## Debug
  echo '###INFO> Archive Lucene, START.'
  ## Archive
  mkdir -p ${ARCHIVEDIR}/lucene
  cp -pr ${LUCENEDIR} ${ARCHIVEDIR}/lucene/.
  ## Debug
  echo '###INFO> Archive Lucene, FINISHED.'


  #### [Step.4] Archive PostgreSQL ####
  ## Debug
  echo '###INFO> Archive PostgreSQL, START.'
  ## Archive
  mkdir -p ${ARCHIVEDIR}/postgresql
  pg_dump ${DBNAME} > ${ARCHIVEDIR}/postgresql/dspace.dump
  ## Debug
  echo '###INFO> Archive PostgreSQL, FINISHED.'


  #### [Step.5] Compression (Option) ####
  ## Debug
  echo '###INFO> Compress Archive Directory, START.'
  ## Compress
  echo -n '###INFO> Compressing... '
  if [ $ARCHIVEMODE = 1 ]; then
    tar -czf ${ARCDIR}/${CURRENTDATE}.tar.gz ${ARCDIR}/${CURRENTDATE}
    rm -rf ${ARCDIR}/${CURRENTDATE}
    echo '[Done]'
  else
    echo '[Pass] (ARCHIVEMODE='${ARCHIVEMODE}')'
  fi
  ## Debug
  echo '###INFO> Compress Archive Directory, FINISHED.'


  #### [Step.6] Rotation ####
  ## Debug
  echo '###INFO> Rotate Archives, START.'
  ## Cleaning
  counter=1
  archivelist=(`ls -r ${ARCDIR}`)
  for alist in ${archivelist[@]}; do
    echo -n '###INFO> Archive #'${counter}': '
    if [ $counter -le $ARCHIVEMAX ]; then
      echo 'archive '${ARCDIR}'/'${alist}'... [keeped]'
    else
      if [ ${alist:0:2} = '20' ]; then  ## Nen-No Tame...
        if [ -d ${ARCDIR}'/'${alist} ]; then
          rm -rf ${ARCDIR}'/'${alist}
        else
          rm -f ${ARCDIR}'/'${alist}
        fi
        echo 'archive '${ARCDIR}'/'${alist}'... [deleted]'
      fi
    fi
    counter=`expr ${counter} + 1`
  done
  ## Debug
  echo '###INFO> Rotate Archives, FINISHED.'

else
  ## Debug
  echo '###INFO> Skip the Archive. ARCHIVEFLAG = ['${ARCHIVEFLAG}']'
fi

## Debug
echo '###INFO> Cleaning Current Directory, START.'

#### Original Code (by STEL, T.Kouno)
rm -rf ImportData_*
rm -rf ReplaceData_*
rm -rf DeleteData
rm -rf runImport.sh
rm -rf runReplace.sh
rm -rf runDelete.sh
rm -rf runClean.sh
rm -rf *.xml
rm -rf *.log

rm -f skip.out  # Add by N.UMEMURA

## Debug
echo '###INFO> Cleaning Current Directory, FINISHED.'

## debug
echo '>>> FINISHED: clean.sh --------------------------------'
