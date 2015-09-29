#!/bin/bash


# ./prepare_release.sh 1 7 0
# https://cwiki.apache.org/confluence/display/FLUME/How+to+Release

# Prepare branches and create tag

X=$1
Y=$2
Z=$3

let "ZN=$Z+1"


git checkout brance-baidu-waimai
git add .
git commit -m "prepare-release"


# Checkout  branch, Remove -SNAPSHOT from the release branch and commit
git checkout -b waimai-branch-$X.$Y.$Z
find . -name pom.xml | xargs sed -i "" -e "s/$X.$Y.$Z-SNAPSHOT/$X.$Y.$Z/"
git add .
git commit -m "Removing -SNAPSHOT from waimai-branch-$X.$Y.$Z branch"
git push origin waimai-branch-$X.$Y.$Z


# make tag
git tag -a waimai-tag-$X.$Y.$Z -m "waimai Flume $X.$Y.$Z release."
git push origin waimai-tag-$X.$Y.$Z


# change $X.$Y.$Z-SNAPSHOT to $X.$Y.$ZN-SNAPSHOT
git checkout brance-baidu-waimai
find . -name pom.xml | xargs sed -i "" -e "s/$X.$Y.$Z-SNAPSHOT/$X.$Y.$ZN-SNAPSHOT/"
git add .
git commit -m "change $X.$Y.$Z-SNAPSHOT to $X.$Y.$ZN-SNAPSHOT"
git push -u origin brance-baidu-waimai:brance-baidu-waimai