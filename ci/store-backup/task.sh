#!/bin/sh

set -e

echo "Storing in $endpoint/$bucket:"
ls backup/*

mc config host add s3 "$endpoint" "$access_key_id" "$secret_access_key"
mc cp backup/* s3/"$bucket"

echo
echo "Result:"
mc ls s3/"$bucket"
