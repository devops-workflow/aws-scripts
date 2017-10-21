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

function deleteTags {
  args=( $@ )
  repo=${args[0]}
  tagType=${args[1]}
  tags=${args[@]:2}
  echo "Delete ${tagType}: ${tags}"
  imageIds=''
  for tag in ${tags}; do
    imageIds="${imageIds} imageTag=${tag}"
  done
  if [ -n "${imageIds}" ]; then
    aws ecr batch-delete-image --repository-name ${repo} --image-ids ${imageIds}
  fi
}

dateCutoff=$(date -d "${daysOld} days ago" +%Y-%m-%d)
dateCutoffSec=$(date -d ${dateCutoff} +%s)
#echo "Date cutoff: ${dateCutoff}, Sec: ${dateCutoffSec}"
for R in $(aws ecr describe-repositories | jq -r .repositories[].repositoryName); do
  echo "Cleaning ECR repository: ${R}"
  tags=$(aws ecr list-images --repository-name ${R} | jq -r .imageIds[].imageTag | sort)
  echo "Tags: ${tags}"
  ### Cleanup date tags
  # Remove data tags older than x days
  tagDates=$(echo "${tags}" | ${grep} '^\d\d\d\d-\d\d-\d\d')
  #echo "Tag Dates: ${tagDates}"
  toDelete=''
  for date in ${tagDates}; do
    dateBase="${date%%_*}"
    dateSec=$(date -d ${dateBase} +%s)
    #echo "Date: ${date}, base: ${dateBase}, Sec: ${dateSec}"
    if [ ${dateCutoffSec} -gt ${dateSec} ]; then
      toDelete="${toDelete} ${date}"
    fi
  done
  deleteTags ${R} dates ${toDelete}
  ### Cleanup version tags
  # Remove any intermediate versions older than the newest release version
  tagVersions=$(echo "${tags}" | ${grep} '^\d+\.\d+\.\d+' | sort -Vr)
  tagVersionsReleases=$(echo "${tagVersions}" | ${grep} '^\d+\.\d+\.\d+$')
  echo "Tag Versions: ${tagVersions}"
  echo "Tag Version Releases: ${tagVersionsReleases}"
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
  deleteTags ${R} versions ${toDelete}
  ### Cleanup single number tags
  # Remove any single number tags, if it is the only tag
  tagNumbers=$(echo "${tags}" | ${grep} '^\d+$')
  echo "Tag numbers: ${tagNumbers}"
  imageList=$(aws ecr list-images --repository-name ${R})
  echo "Image list: $(echo "${imageList}" | jq .)"
done
