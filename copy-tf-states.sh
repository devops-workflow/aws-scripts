#!/bin/bash
#
# Copy terraform state files from one s3 location to another and rename them
#

env='one'
env='test'
org='wiser'
s3bucket="${org}-${env}-tf"
s3uri="s3://${s3bucket}"
awsCmd='aws'
#awsCmd='aws --profile saml'
for F in $(${awsCmd} s3 ls ${s3uri} --recursive | grep terraform.tfstate | awk '{ print $4 }'); do
  stack=$(dirname ${F})
  ${awsCmd} s3 cp ${s3uri}/${F} ${s3uri}/services/${stack}.tfstate --dryrun
done
