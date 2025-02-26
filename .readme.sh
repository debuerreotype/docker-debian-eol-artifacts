#!/usr/bin/env bash
set -Eeuo pipefail

dir="$(dirname "$BASH_SOURCE")"
dir="$(cd "$dir" && pwd -P)"

suites="$(
	sed -r 's/[[:space:]]*#.*$//' "$dir/suites" \
		| grep -vE '^$' \
		| cut -d' ' -f1 \
		| tac
)"

# https://github.com/debuerreotype/docker-debian-eol-artifacts/tree/pre-apt
suites+='
	hamm
	bo
	rex
	buzz
'

exec docker run --rm -v "$dir/.readme.pl":/eol.pl:ro tianon/mojo perl /eol.pl $suites
