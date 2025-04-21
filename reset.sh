#!/usr/bin/env bash
#
# rewrite‑git‑identity.sh
# Usage:  ./rewrite-git-identity.sh "old@email.com" "New Name" "new@email.com"
#
# 1. cd into the repo
# 2. chmod +x rewrite-git-identity.sh
# 3. ./rewrite-git-identity.sh "<OLD_EMAIL>" "<NEW_NAME>" "<NEW_EMAIL>"
# 4. git push --force --tags   # or --force-with-lease

set -euo pipefail

OLD_EMAIL="$1"
NEW_NAME="$2"
NEW_EMAIL="$3"

echo "Rewriting commits..."
git filter-branch -f --env-filter "
    if [ \"\$GIT_COMMITTER_EMAIL\" = \"$OLD_EMAIL\" ]; then
        export GIT_COMMITTER_NAME=\"$NEW_NAME\"
        export GIT_COMMITTER_EMAIL=\"$NEW_EMAIL\"
    fi
    if [ \"\$GIT_AUTHOR_EMAIL\" = \"$OLD_EMAIL\" ]; then
        export GIT_AUTHOR_NAME=\"$NEW_NAME\"
        export GIT_AUTHOR_EMAIL=\"$NEW_EMAIL\"
    fi
" --tag-name-filter cat -- --branches --tags

echo
echo "✅  Done.  Now run:  git push --force --tags   (or --force-with-lease)"
