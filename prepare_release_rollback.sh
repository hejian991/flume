#!/bin/bash


# ./prepare_release_rollback.sh 1 7 0 $shaId
# 回滚 prepare_release

X=$1
Y=$2
Z=$3

let "ZN=$Z+1"

git checkout brance-baidu-waimai


git branch -D waimai-branch-$X.$Y.$Z
git push origin :waimai-branch-$X.$Y.$Z


git tag -d waimai-tag-$X.$Y.$Z
git push origin :refs/tags/waimai-tag-$X.$Y.$Z


git reset --hard $4
git push origin HEAD --force


