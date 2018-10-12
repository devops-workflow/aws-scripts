#!/usr/bin/env bash

encrypted_text=$1

aws kms decrypt --ciphertext-blob fileb://<(echo "${encrypted_text}" | base64 --decode) --output text --query Plaintext | base64 --decode
