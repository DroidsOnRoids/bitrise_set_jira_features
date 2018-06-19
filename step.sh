#!/usr/bin/env bash

set -e

JIRA_ESCAPED_URL=$(echo ${jira_project_prefix} | sed -e "s#/#\\\/#g")

git log --pretty=format:"%s" | grep "$jira_default_url[0-9]{0,5}" -o -E | sort -u -r | sed -e 's/^/'${JIRA_ESCAPED_URL}'/' | envman add --key GIT_RELEASE_NOTES

echo "Features:"
echo ""
envman run bash -c 'echo "$GIT_RELEASE_NOTES"'