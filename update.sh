#!/bin/bash

repo='https://github.com/git-guilt/guilt.git'

set -e

rm -f last_hash.new

last_hash=$(cat last_hash) || {
	echo "Cannot read last hash saved" >&2
	exit 1
}
set -- $(git ls-remote --heads "$repo" refs/heads/master)
if [ "$2" != "refs/heads/master" ]; then
	echo "Error fetching last hash" >&2
	exit 1
fi
hash_="$1"
if [ "$hash_" = "$last_hash" ]; then
	echo "No update, we are good"
	exit 0
fi

# Do the real update
rm -rf guilt
git clone "$repo"
(cd guilt && make doc)
git rm docs/*.html
mkdir -p docs
cp guilt/Documentation/*.html docs/
(cd docs && cp guilt.html index.html && git add *.html)
echo "$hash_" > last_hash.new
mv -f last_hash.new last_hash
git add last_hash
git commit -m "Updated to $hash_"

echo "Everything done, git push to publish the change!"
