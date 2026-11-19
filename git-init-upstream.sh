#!/bin/sh

#
# Sets up an upstream remote for the project.
#
# Call with "uninit" to remove upstream and all its refs.
#
# NOTE: Upstream tags are never fetched to keep the project's own tag space clean. Cherry-picking
# and merging can be done using commit SHAs, and commits matching an upstream tag can be obtained
# with:
#
#   git ls-remote upstream 'refs/tags/<TAG>*'
#
# For an annotated tag, use the ^{} line?s SHA.
#

set -e

upstream_url='https://gitlab.com/libpipeline/libpipeline.git'
remote=upstream

remove_upstream()
{
  if git config --get "remote.$remote.url" >/dev/null 2>&1; then
    git remote remove "$remote"
  fi

  # Also remove any leftover remote-tracking references.
  git for-each-ref --format='delete %(refname)' "refs/remotes/$remote/" |
    git update-ref --stdin
}

case ${1-} in
  '')
    ;;
  uninit)
    remove_upstream
    exit 0
    ;;
  *)
    echo "Usage: $0 [uninit]" >&2
    exit 2
    ;;
esac

current_url=$(git config --get "remote.$remote.url" 2>/dev/null || :)

if [ "$current_url" = "$upstream_url" ]; then
  echo "$remote already points to $upstream_url"
  exit 0
fi

if [ -n "$current_url" ]; then
  echo "Replacing $remote:"
  echo "  old: $current_url"
  echo "  new: $upstream_url"
  remove_upstream
fi

git remote add upstream "$upstream_url"
git config remote.upstream.tagOpt --no-tags
git fetch upstream
