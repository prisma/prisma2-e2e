#!/bin/sh

set -eux

branch="$1"
version=$(sh .github/scripts/prisma-version.sh "$branch")

echo "$version" > .github/prisma-version.txt

echo "upgrading all packages (upgrade-all.sh)"

packages=$(find "." -not -path "*/node_modules/*" -type f -name "package.json")

dir=$(pwd)

echo "$packages" | tr ' ' '\n' | while read -r item; do
	case "$item" in
		*".github"*|*"yarn-workspaces/package.json"*|*"functions/generated/client"*)
			echo "ignoring $item"
			continue
			;;
	esac

	echo "running $item"
	cd "$(dirname "$item")/"

	## ACTION
	yarn add "@prisma/cli@$branch" --dev
	yarn add "@prisma/client@$branch"
	## END

	echo "$item done"
	cd "$dir"
done

echo "done upgrading all packages (upgrade-all.sh)"
