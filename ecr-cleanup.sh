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
# TODO: set AWS region
export AWS_DEFAULT_REGION=us-west-2
export AWS_REGION=${AWS_DEFAULT_REGION}
daysOld=5
dateCutoff=$(date -d '5 days ago' +%Y-%m-%d)
dateCutoffSec=$(date -d ${dateCutoff} +%s)
for R in $(aws ecr describe-repositories | jq -r .repositories[].repositoryName); do
  echo "Cleaning ECR repository: ${R}"
  tags=$(aws ecr list-images --repository-name ${R} | jq -r .imageIds[].imageTag | sort)
  tagDates=$(echo "${tags}" | grep -E '^\d\d\d\d-\d\d-\d\d')
  tagVersions=$(echo "${tags}" | grep -E '^\d+\.\d+\.\d+')
  echo "Tags: ${tags}"
  echo "Tag Dates: ${tagDates}"
  echo "Tag Versions: ${tagVersions}"
  #for T in ${tags}; do
  #  echo $T
  #done
  ### Cleanup date tags
  toDelete=''
  for date in ${tagDates}; do
    # TODO: move to python for more portable data manipulation ?
    dateBase="${date%%_*}"
    dateSec=$(date -d ${dateBase} +%s)
    if [ ${dateCutoffSec} -gt ${dateSec} ]; then
      toDelete="${toDelete} ${date}"
    fi
  done
  echo "Delete dates: ${toDelete}"
  #aws ecr batch-delete-image --repository-name ${R} --image-ids imageTag=a imageTag=b
  ### Cleanup version tags
  ### Cleanup single number tags
done
