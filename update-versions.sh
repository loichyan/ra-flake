#!/usr/bin/env bash

declare -a rust_releases ra_releases

log() {
	echo "$@" 1>&2
}

get_releases() {
	local repo="${1}"
	log "Fetching releases of ${repo}"
	gh api "repos/${repo}/releases" --paginate -q '.[] | [.tag_name, .created_at] | join(",")'
}

find_versions() {
	local latest_ra
	local -i i j
	for ((i = 0, j = 0; ; j++)); do
		IFS=',' read -r rust_ver rust_date <<<"${rust_releases[$i]}"
		IFS=',' read -r ra_ver ra_date <<<"${ra_releases[$j]}"
		if [[ -z "${rust_ver}" ]] || [[ -z "${ra_ver}" ]]; then
			break
		elif [[ "${ra_ver}" == "nightly" ]]; then
			# Skip nightly release
			continue
		fi
		# Record the latest release.
		latest_ra="${latest_ra:-${ra_ver}}"
		# Find the latest rust-analyzer between two releases of Rust
		if [[ "${ra_date}" < "${rust_date}" ]]; then
			i+=1
			printf '["%s", "%s"]\n' "${rust_ver}" "${latest_ra}"
			latest_ra="${ra_ver}"
		fi
	done
}

declare output
while getopts "o:" arg; do
	case "${arg}" in
	o)
		output=$OPTARG
		;;
	*)
		exit 1
		;;
	esac
done
if [[ -z "${output}" ]]; then
	log "Missing argument -o"
	exit 1
fi

read -ra rust_releases -d '\n' < <(get_releases rust-lang/rust)
read -ra ra_releases -d '\n' < <(get_releases rust-lang/rust-analyzer)
find_versions | jq -s '[.[] | {rust: .[0], rust_analyzer: .[1]}]' >"${output}"
