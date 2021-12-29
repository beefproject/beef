#!/bin/bash

git checkout -b "release/$2"
sed -i '' -e "s/$1/$2/g" VERSION
sed -i '' -e "s/\"version\": \"$1\"/\"version\": \"$2\"/g" package.json
sed -i '' -e "s/\"version\": \"$1\"/\"version\": \"$2\"/g" package-lock.json
sed -i '' -e "s/\"version\": \"$1\"/\"version\": \"$2\"/g" config.yaml

if [[ "$1" != *"-pre"* ]]; then
  sed -i '' -e "s/v$1/v$2/g" .github/ISSUE_TEMPLATE.md
fi

git add VERSION package.json package-lock.json config.yaml
git commit -m "Version bump $2"
git push --set-upstream origin release/$2
git push
