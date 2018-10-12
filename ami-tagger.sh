#!/bin/bash
#
# Tag an AMI account all the accounts that have access to it
#
# https://aws.amazon.com/premiumsupport/knowledge-center/iam-assume-role-cli/
# https://aws.amazon.com/blogs/security/how-to-use-a-single-iam-user-to-easily-access-all-your-accounts-by-using-the-aws-cli/
#
ami=
# Get accounts
# Get tags
# for A in $accounts; do
# if A = current account skip
# assume role & apply tags
#aws sts get-caller-identity
#aws iam list-roles --query
#aws sts assume-role --role-arn
