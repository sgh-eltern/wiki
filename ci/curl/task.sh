#!/bin/sh

set -e
curl -v "$url" > result/response

echo
echo "Result:"
< result/response jq -r .code | tee result/code

echo
echo "Screenshot:"
< result/response jq -r .data[].screenshot.original.defaultUrl | tee result/screenshot

echo
echo "Video:"
< result/response jq -r .data[].video.url | tee result/video
