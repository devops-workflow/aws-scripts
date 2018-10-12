#!/bin/bash
#
# Remove terraform state files
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
  ${awsCmd} s3 rm ${s3uri}/${F} --dryrun
done
