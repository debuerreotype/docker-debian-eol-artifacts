#!/usr/bin/env bash
set -Eeuo pipefail

targetRepo='debian/eol'

targetRegistry='https://registry-1.docker.io'
#targetRegistry='http://registry.docker:5000'

gitHubRepo='https://github.com/debuerreotype/docker-debian-eol-artifacts'

_arch_to_go_arch() {
	case "$1" in
		i386) echo '386' ;;
		arm32*) echo 'arm' ;;
		arm64*) echo 'arm64' ;;
		*) echo "$arch" ;;
	esac
}
_arch_to_variant() {
	case "$1" in
		arm32v*) echo "${1#arm32v}" ;;
		arm64v*) echo "${1#arm64v}" ;;
	esac
}
_arch_to_platform() {
	arch="$(_arch_to_go_arch "$1")"
	variant="$(_arch_to_variant "$1")"
	jq -c -n \
		--arg arch "$arch" \
		--arg variant "$variant" \
		'{
			"os": "linux",
			"architecture": $arch
		} + if ($variant | length) > 0 then {"variant": $variant} else null end'
}

curl_auth() {
	local token=
	if [ "$targetRegistry" = 'https://registry-1.docker.io' ]; then
		local auth; auth="$(jq -r '.auths."https://index.docker.io/v1/".auth' ~/.docker/config.json | base64 -d)"
		[ -n "$auth" ]

		token="$(curl -fsSL "https://$auth@auth.docker.io/token?service=registry.docker.io&scope=repository:$targetRepo:push,pull" | jq --raw-output '.token')"
	fi

	if [ -n "$token" ]; then
		curl -H "Authorization: Bearer $token" "$@"
	else
		curl "$@"
	fi
}

put_blob() {
	local digest="$1"; shift
	local blob="$1"; shift

	local fack loc
	fack="$(curl_auth -X POST "$targetRegistry/v2/$targetRepo/blobs/uploads/" -fsSL -D- | tr -d '\r')"
	loc="$(grep -i 'Location:' <<<"$fack" | sed -r 's/^.+:[[:space:]]+//')"
	[ -n "$loc" ]

	curl_auth -fL -X PUT -H 'Content-Type: application/octet-stream' --data-raw "$blob" "$loc&digest=$digest"
}
put_blob_file() {
	local digest="$1"; shift
	local blobFile="$1"; shift

	local fack loc
	fack="$(curl_auth -X POST "$targetRegistry/v2/$targetRepo/blobs/uploads/" -fsSL -D- | tr -d '\r')"
	loc="$(grep -i 'Location:' <<<"$fack" | sed -r 's/^.+:[[:space:]]+//')"
	[ -n "$loc" ]

	curl_auth -fL -X PUT -H 'Content-Type: application/octet-stream' --data-binary "@$blobFile" "$loc&digest=$digest"
}
put_manifest() {
	local tagOrDigest="$1"; shift
	local manifest="$1"; shift

	curl_auth -fL -X PUT -H "Content-Type: $(jq -r '.mediaType' <<<"$manifest")" --data-raw "$manifest" "$targetRegistry/v2/$targetRepo/manifests/$tagOrDigest"
}

digest() {
	local blob="$1"; shift
	local digest; digest="$(echo -n "$blob" | sha256sum | cut -d' ' -f1)"
	echo "sha256:$digest"
}
digest_file() {
	local blobFile="$1"; shift
	local digest; digest="$(sha256sum < "$blobFile" | cut -d' ' -f1)"
	echo "sha256:$digest"
}

for suite; do
	dir="$(mktemp -d)"
	trap "rm -rf $(printf '%q' "$dir")" EXIT
	cd "$dir"

	commit="$(git ls-remote "$gitHubRepo.git" "refs/heads/dist-$suite" | cut -d$'\t' -f1)"
	[ -n "$commit" ]

	stamp="$(
		wget -qO- "$gitHubRepo/raw/$commit/suites" \
			| sed -r 's/[[:space:]]*#.*$//' \
			| grep -vE '^$' \
			| awk -v suite="$suite" '$1 == suite { print $2; exit }'
	)"
	created="$(TZ=UTC date --date "$stamp" '+%Y-%m-%dT%H:%M:%S.%NZ')"

	arches="$(wget -qO- "$gitHubRepo/raw/$commit/$suite/arches")"

	for variant in '' slim; do
		manifestList="$(jq -c -n '{
			"schemaVersion": 2,
			"mediaType": "application/vnd.docker.distribution.manifest.list.v2+json",
			"manifests": []
		}')"

		for arch in $arches; do
			targetDir="$arch${variant:+-$variant}"
			mkdir -p "$targetDir"

			echo "$suite${variant:+-$variant} ($arch)"

			rootfs="$targetDir/rootfs.tar"
			wget --quiet --show-progress --progress=dot:giga -O "$rootfs.xz" "$gitHubRepo/raw/$commit/$suite/$arch${variant:+"/$variant"}/rootfs.tar.xz"
			echo

			xz -d < "$rootfs.xz" > "$rootfs"
			gzip --no-name < "$rootfs" > "$rootfs.gz"
			imageId="$(digest_file "$rootfs.xz")"
			layerId="$(digest_file "$rootfs")"
			rootfsDigest="$(digest_file "$rootfs.gz")"
			echo "rootfs: $rootfsDigest"

			platform="$(_arch_to_platform "$arch")"

			config="$(
				jq -c -n \
					--argjson platform "$platform" \
					--arg image "$imageId" \
					--arg layer "$layerId" \
					--arg created "$created" \
					--arg url "$gitHubRepo/tree/$commit/$suite/$arch${variant:+"/$variant"}" \
					'$platform + {
						"config": {
							"Env": [ "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" ],
							"Cmd": [ "bash" ],
							"Image": $image
						},
						"created": $created,
						"history": [ {
							"created": $created,
							"created_by": $url
						} ],
						"rootfs": {
							"type": "layers",
							"diff_ids": [ $layer ]
						}
					}'
			)"
			configDigest="$(digest "$config")"

			manifest="$(
				jq -c -n \
					--arg configSize "${#config}" \
					--arg configDigest "$configDigest" \
					--arg rootfsSize "$(stat -c '%s' "$rootfs.gz")" \
					--arg rootfsDigest "$rootfsDigest" \
					'{
						"schemaVersion": 2,
						"mediaType": "application/vnd.docker.distribution.manifest.v2+json",
						"config": {
							"mediaType": "application/vnd.docker.container.image.v1+json",
							"size": ($configSize | tonumber),
							"digest": $configDigest
						},
						"layers": [
							{
								"mediaType": "application/vnd.docker.image.rootfs.diff.tar.gzip",
								"size": ($rootfsSize | tonumber),
								"digest": $rootfsDigest
							}
						]
					}'
			)"
			manifestDigest="$(digest "$manifest")"

			put_blob_file "$rootfsDigest" "$rootfs.gz"
			put_blob "$configDigest" "$config"

			put_manifest "$manifestDigest" "$manifest"

			manifestList="$(
				jq -c <<<"$manifestList" \
					--arg manifestSize "${#manifest}" \
					--arg manifestDigest "$manifestDigest" \
					--argjson platform "$platform" \
					'.manifests += [{
						"mediaType": "application/vnd.docker.distribution.manifest.v2+json",
						"size": ($manifestSize | tonumber),
						"digest": $manifestDigest,
						"platform": $platform
					}]'
			)"
		done

		amd64="$(jq '.manifests[] | select(.platform.architecture == "amd64")' <<<"$manifestList")"
		i386="$(jq '.manifests[] | select(.platform.architecture == "386")' <<<"$manifestList")"
		if [ -z "$amd64" ] && [ -n "$i386" ]; then
			# if we have an i386 image but not an amd64 image, use the i386 image *as* the amd64 image
			# TODO fix https://github.com/moby/moby/issues/34875 properly instead so i386 is a valid fallback platform on amd64...
			amd64="$(
				jq -c <<<"$i386" \
					'.platform.architecture = "amd64"'
			)"
			manifestList="$(
				jq -c <<<"$manifestList" \
					--argjson manifest "$amd64" \
					'.manifests += [ $manifest ]'
			)"
		fi

		manifestListDigest="$(digest "$manifestList")"
		put_manifest "$manifestListDigest" "$manifestList"

		tag="$suite${variant:+-$variant}"
		put_manifest "$tag" "$manifestList"

		echo
		echo "- $targetRepo@$manifestListDigest"
		echo "- $targetRepo:$tag"
		echo
	done

	cd ..
	rm -rf "$dir"
	trap - EXIT
done
