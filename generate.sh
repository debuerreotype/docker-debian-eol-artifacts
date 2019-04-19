#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
	printf 'usage: DEBUERREOTYPE_DIRECTORY=... %q suite\n' "$0"
	printf '   ie: DEBUERREOTYPE_DIRECTORY=... %q lenny\n' "$0"
}

: "${DEBUERREOTYPE_DIRECTORY:?'missing; should be set to the location of a debuerreotype repository checkout for "build.sh"'}"
buildSh="$DEBUERREOTYPE_DIRECTORY/build.sh"
{ [ -s "$buildSh" ] && [ -x "$buildSh" ]; } || { usage >&2; exit 1; }

_read_file() {
	local file="$1"; shift
	local array="$1"; shift
	local dataArray="$1"; shift

	local -
	# disable file globbing
	set -f

	local IFS=$'\n'
	set -- $(sed -r 's/[[:space:]]*#.*$//' "$file" | grep -vE '^$')
	unset IFS

	eval "declare -g -a $array=(); declare -g -A $dataArray=()"
	while [ "$#" -gt 0 ]; do
		local line="$1"; shift
		local lineData=( $line )
		local key="${lineData[0]}"

		eval "$array+=( $(printf '%q' "$key") )"
		local -i i
		for (( i = 0; i < ${#lineData[@]}; ++i )); do
			eval "$dataArray[${key}_$i]=$(printf '%q' "${lineData[$i]}")"
		done
	done
}

_read_file arches dpkgArches dpkgArchData
_read_file suites suites suiteData

suite="${1:?'missing "suite" argument'}" || { usage >&2; exit 1; }
timestamp="${suiteData[${suite}_1]}"
arches="$(
	# for EOL releases, we don't really care so much about security support, so grab the full list of suite architectures
	wget -qO- "http://archive.debian.org/debian/dists/$suite/Release" \
		| awk -F ': ' '$1 == "Architectures" { print $2 }'
)"

_intersection() {
	local set1="$1"; shift
	local set2="$1"; shift
	comm -12 <(xargs -n1 <<<"$set1" | sort -u) <(xargs -n1 <<<"$set2" | sort -u)
}

arches="$(_intersection "$arches" "${dpkgArches[*]}")"
if grep -qE '^arm$' <<<"$arches" && grep -qE '^arm(el|hf)$' <<<"$arches"; then
	# if we have either "armel" or "armhf", ignore the ancient "arm" (lenny)
	arches="$(grep -vE '^arm$' <<<"$arches")"
fi
arches="$(xargs <<<"$arches")"

echo "$suite ($timestamp) arches: $arches"
sleep 1

rm -rf "$suite"
for arch in $arches; do
	bashbrewArch="${dpkgArchData[${arch}_1]}"
	target="$suite/$bashbrewArch"

	# TODO put temporary "output" elsewhere? (mktemp -d?)
	out="output-$suite-$arch"
	rm -rf "$out"
	"$DEBUERREOTYPE_DIRECTORY/build.sh" --eol --arch "$arch" "$out" "$suite" "$timestamp"
	mkdir -p "$(dirname "$target")"
	mv -T "$out/"*"/$arch/$suite" "$target"
	rm -rf "$out"

	echo "$bashbrewArch" >> "$suite/arches"
done
