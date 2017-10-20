#!/bin/bash
#
# Reaper script for ECR repositories
#
# Clean all ECR repositories in AWS account
#
for R in $(aws ecr describe-repositories | jq -r .repositories[].repositoryName); do
  tags=$(aws ecr list-images --repository-name ${R} | jq -r .imageIds[].imagetTag)
  #aws ecr batch-delete-image --repository-name ${R} --image-ids imageTag=a imageTag=b
done
