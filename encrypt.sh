#!/usr/bin/env bash

cleartext=$1

aws kms encrypt --key-id 'alias/wiser/lambda' --plaintext "${cleartext}" --query CiphertextBlob --output text

# aws kms encrypt --key-id $(aws kms list-aliases --query "Aliases[?AliasName == 'alias/wiser/lambda'].TargetKeyId" --output text) --plaintext "${cleartext}" --query CiphertextBlob --output text
