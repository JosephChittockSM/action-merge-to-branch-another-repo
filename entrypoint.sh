#!/bin/sh

set -e
set -x

if [ -z "$INPUT_SOURCE_FOLDER" ]
then
  echo "Source folder must be defined"
  return -1
fi

if [ $INPUT_DESTINATION_HEAD_BRANCH == "main" ] || [ $INPUT_DESTINATION_HEAD_BRANCH == "master"]
then
  echo "Destination head branch cannot be 'main' nor 'master'"
  return -1
fi

CLONE_DIR=$(mktemp -d)

echo "Setting git variables"
export GITHUB_TOKEN=$API_TOKEN_GITHUB
git config --global user.email "$INPUT_USER_EMAIL"
git config --global user.name "$INPUT_USER_NAME"

echo "Cloning destination git repository"
git clone "https://$API_TOKEN_GITHUB@github.com/$INPUT_DESTINATION_REPO.git" "$CLONE_DIR"

echo "Copying contents to git repo"
mkdir -p $CLONE_DIR/$INPUT_DESTINATION_FOLDER/
cp $INPUT_SOURCE_FOLDER "$CLONE_DIR/$INPUT_DESTINATION_FOLDER/"
cd "$CLONE_DIR"

if [ -z "$INPUT_TRIGGER_FILE" ]
then
  echo "No files to rename"
else
  echo "Renaming"
  mv $INPUT_DESTINATION_FOLDER/$INPUT_TRIGGER_FILE.frag $INPUT_DESTINATION_FOLDER/$INPUT_NEW_NAME.frag
  mv $INPUT_DESTINATION_FOLDER/$INPUT_TRIGGER_FILE.vert $INPUT_DESTINATION_FOLDER/$INPUT_NEW_NAME.vert
fi

git checkout "$INPUT_DESTINATION_HEAD_BRANCH"

echo "Adding git commit"
git add .
if git status | grep -q "Changes to be committed"
then
  git commit --message "$INPUT_COMMIT_MESSAGE"
  git push origin $INPUT_DESTINATION_HEAD_BRANCH
else
  echo "No changes detected"
fi
