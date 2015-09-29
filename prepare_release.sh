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

# 7. Checkout the release branch:
git checkout brance-baidu-waimai
git checkout -b waimai-branch-$X.$Y.$Z

# 8. Remove -SNAPSHOT from the release branch and commit
find . -name pom.xml | xargs sed -i "" -e "s/$X.$Y.$Z-SNAPSHOT/$X.$Y.$Z/"
git add .
git commit -m "Removing -SNAPSHOT from waimai-branch-$X.$Y.$Z branch"
git tag -a waimai-tag-$X.$Y.$Z -m "waimai Flume $X.$Y.$Z release."
git push origin waimai-tag-$X.$Y.$Z
#git tag -d release-$X.$Y.$Z
#git push origin :refs/tags/release-$X.$Y.$Z



git checkout brance-baidu-waimai
find . -name pom.xml | xargs sed -i "" -e "s/$X.$Y.$Z-SNAPSHOT/$X.$Y.$ZN-SNAPSHOT/"
git add .
git commit -m "change $X.$Y.$Z-SNAPSHOT to $X.$Y.$ZN-SNAPSHOT"
git push -u origin brance-baidu-waimai:brance-baidu-waimai

# git checkout waimai-tag-release-$X.$Y.$Z
