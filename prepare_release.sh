#!/bin/bash

# https://cwiki.apache.org/confluence/display/FLUME/How+to+Release
# 3. Update the "version" value of all pom.xml and RELEASE-NOTES in trunk to X.(Y+1).0:
git checkout trunk
find . -name pom.xml | xargs sed -i "" -e "s/X.Y.0-SNAPSHOT/X.$(Y+1).0-SNAPSHOT/"
find flume-ng-doc/ -name "*.rst" | xargs  sed -i "" -e "s/X.Y.0-SNAPSHOT/X.$(Y+1).0-SNAPSHOT/"
vim RELEASE-NOTES
git add .
git commit -m "FLUME-XXXX: Preparing for the X.Y release"


# 4. Find hash for use later
git log

# 5. Create a branch for the X.(Y+1) release series
# E.g. flume-1.5 should be branched off of flume-1.4
git checkout flume-X.Y
git checkout -b flume-X.(Y+1)
git cherry-pick <hash from the previous step>
# 6. Push the changes up stream
git push -u origin trunk:trunk
git push -u origin flume-X.Y:flume-X.Y
# 7. Checkout the release branch:
git checkout flume-X.Y
# 8. Remove -SNAPSHOT from the release branch and commit
find . -name pom.xml | xargs sed -i "" -e "s/X.Y.0-SNAPSHOT/X.Y.0/"
find flume-ng-doc/ -name "*.rst" | xargs  sed -i "" -e "s/X.Y.0-SNAPSHOT/X.Y.0/"
git add .
git commit -m "FLUME-XXXX: Removing -SNAPSHOT from X.Y branch"
# 9. Ensure RELEASE-NOTES has the appropriate version and description of the release.
# 10. Tag a candidate:
git tag -a release-X.Y.Z -m "Apache Flume X.Y.Z release."
git push origin release-X.Y.Z

# If an rc1, rc2, etc is needed, delete that tag before creating a new one:
# git tag -d release-X.Y.Z
# git push origin :refs/tags/release-X.Y.Z