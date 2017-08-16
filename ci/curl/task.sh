#!/bin/sh

set -e

curl "$url" 2> result/log > result/response
