#!/usr/bin/env bash

set -e # exit with nonzero exit code if anything fails

# get GIT url

GIT_URL=`git config --get remote.origin.url`
if [[ ${GIT_URL} == "" ]]; then
  echo "This project is not configured with a remote git repo".
  exit 1
fi

# clear and re-create the out directory
rm -rf .tmp || exit 0;
mkdir .tmp;

# run our compile script, discussed above
npm run scss
npm run catalog-build

# go to the out directory and create a *new* Git repo
cd .tmp
git init

# inside this git repo we'll pretend to be a new user
git config user.name "GH Pages Bot"
git config user.email "hello@ghbot.com"

# The first and only commit to this new Git repo contains all the
# files present with the commit message "Deploy to GitHub Pages".
git add .
git commit -m "Deploy Catalog to GitHub Pages"

# Force push from the current repo's master branch to the remote
# repo's gh-pages branch. (All previous history on the gh-pages branch
# will be lost, since we are overwriting it.) We redirect any output to
# /dev/null to hide any sensitive credential data that might otherwise be exposed.
git push --force --quiet ${GIT_URL} master:gh-pages > /dev/null 2>&1
#git push --force ${GIT_URL} master:gh-pages
cd ..
rm -rf .tmp

echo ""
echo "=> Storybook deployed to: `node scripts/getUrl.js $GIT_URL`"