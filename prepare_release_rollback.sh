#!/bin/bash


# ./prepare_release.sh 1 7 0
# https://cwiki.apache.org/confluence/display/FLUME/How+to+Release

# Prepare branches and create tag
# In this section, the release is X.Y.Z (e.g. 1.3.0)

# 3. Update the "version" value of all pom.xml and RELEASE-NOTES in trunk to X.(Y+1).0:

X=$1
Y=$2
Z=$3

let "ZN=$Z+1"


git branch -D waimai-branch-$X.$Y.$Z

git tag -d waimai-tag-$X.$Y.$Z
git push origin :refs/tags/waimai-tag-$X.$Y.$Z



# git checkout waimai-tag-release-$X.$Y.$Z
