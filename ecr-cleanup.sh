#!/bin/bash
#
# Reaper script for ECR repositories
#
# Clean all ECR repositories in AWS account
#
# Cleanup rules:
#   YYYY-MM-DD*         older than x days
#   x.y.z-d-sha         if newer x.y.z exists
#   d                   If no other tags
#   x.y.z-d-sha         No more than x per tag version
#
# TODO: move to python to make more portable ?
# TODO: set AWS region
export AWS_DEFAULT_REGION=us-west-2
export AWS_REGION=${AWS_DEFAULT_REGION}
daysOld=5
#grep='grep -E'  # Mac
grep='grep -P'  # Linux
dateCutoff=$(date -d "${daysOld} days ago" +%Y-%m-%d)
dateCutoffSec=$(date -d ${dateCutoff} +%s)
#echo "Date cutoff: ${dateCutoff}, Sec: ${dateCutoffSec}"
for R in $(aws ecr describe-repositories | jq -r .repositories[].repositoryName); do
  echo "Cleaning ECR repository: ${R}"
  tags=$(aws ecr list-images --repository-name ${R} | jq -r .imageIds[].imageTag | sort)
  tagDates=$(echo "${tags}" | ${grep} '^\d\d\d\d-\d\d-\d\d')
  tagVersions=$(echo "${tags}" | ${grep} '^\d+\.\d+\.\d+' | sort -Vr)
  tagVersionsReleases=$(echo "${tagVersions}" | ${grep} '^\d+\.\d+\.\d+$')
  echo "Tags: ${tags}"
  #echo "Tag Dates: ${tagDates}"
  echo "Tag Versions: ${tagVersions}"
  echo "Tag Version Releases: ${tagVersionsReleases}"
  ### Cleanup date tags
  toDelete=''
  for date in ${tagDates}; do
    dateBase="${date%%_*}"
    dateSec=$(date -d ${dateBase} +%s)
    #echo "Date: ${date}, base: ${dateBase}, Sec: ${dateSec}"
    if [ ${dateCutoffSec} -gt ${dateSec} ]; then
      toDelete="${toDelete} ${date}"
    fi
  done
  echo "Delete dates: ${toDelete}"
  imageIds=''
  for date in ${toDelete}; do
    imageIds="${imageIds} imageTag=${date}"
  done
  if [ -n "${imageIds}" ]; then
    aws ecr batch-delete-image --repository-name ${R} --image-ids ${imageIds}
  fi
  ### Cleanup version tags
  toDelete=''
  foundRelease=''
  for version in ${tagVersions}; do
    echo "${version}" | ${grep} -q '^\d+\.\d+\.\d+$'
    if [ $? -eq 0 ]; then
      foundRelease='true'
    elif [ "${foundRelease}" == 'true' ]; then
      toDelete="${toDelete} ${version}"
    fi
  done
  echo "Delete versions: ${toDelete}"
  ### Cleanup single number tags
done
