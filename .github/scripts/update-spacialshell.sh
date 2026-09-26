#!/usr/bin/env bash
# Bump Casks/spacialshell.rb to the latest published SpacialShell release.
#
# Reads the latest release of AskAlice/SpacialShell-MacOS (the /releases/latest endpoint never
# returns drafts or prereleases), requires a vX.Y.Z tag with an uploaded SpacialShell-X.Y.Z.dmg,
# downloads the DMG, and rewrites `version` and `sha256` only when they differ from the cask.
# Never moves the cask backwards. Exits 0 with no changes when there is nothing to do.
#
# Needs: gh (authenticated via GH_TOKEN), curl, sha256sum or shasum, sed, sort -V.
# Writes `changed=true|false` and `version=X.Y.Z` to $GITHUB_OUTPUT when set.
set -euo pipefail

REPO="${SPACIALSHELL_REPO:-AskAlice/SpacialShell-MacOS}"
CASK="${CASK:-Casks/spacialshell.rb}"
out="${GITHUB_OUTPUT:-/dev/null}"

note() { printf '%s\n' "$*" >&2; }
finish() { echo "changed=$1" >>"$out"; echo "version=${2:-}" >>"$out"; exit 0; }

release="$(gh api "repos/$REPO/releases/latest")"
tag="$(jq -r '.tag_name' <<<"$release")"
if [[ "$(jq -r '.draft or .prerelease' <<<"$release")" != "false" ]]; then
  note "Latest release $tag is a draft or prerelease; skipping."; finish false
fi
if [[ ! "$tag" =~ ^v([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
  note "Latest release tag '$tag' is not vX.Y.Z; skipping."; finish false
fi
version="${BASH_REMATCH[1]}"
asset="SpacialShell-$version.dmg"

asset_json="$(jq -c --arg n "$asset" '[.assets[] | select(.name == $n and .state == "uploaded")][0] // empty' <<<"$release")"
if [[ -z "$asset_json" ]]; then
  note "Release $tag has no uploaded $asset (yet); skipping."; finish false
fi

current_version="$(sed -nE 's/^  version "([^"]+)"$/\1/p' "$CASK")"
current_sha="$(sed -nE 's/^  sha256 "([0-9a-f]{64})"$/\1/p' "$CASK")"
if [[ -z "$current_version" || -z "$current_sha" ]]; then
  note "Could not read version/sha256 from $CASK."; exit 1
fi

newest="$(printf '%s\n%s\n' "$current_version" "$version" | sort -V | tail -n1)"
if [[ "$newest" != "$version" ]]; then
  note "Latest release $version is older than the cask's $current_version; not downgrading."; finish false
fi

# The API publishes the asset's digest; when it already matches the cask, skip the download.
api_sha="$(jq -r '.digest // "" | sub("^sha256:"; "")' <<<"$asset_json")"
if [[ "$version" == "$current_version" && "$api_sha" == "$current_sha" ]]; then
  note "Cask already at $version ($current_sha)."; finish false
fi

url="https://github.com/$REPO/releases/download/$tag/$asset"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
note "Downloading $url"
curl -fsSL --retry 3 -o "$tmp/$asset" "$url"
if command -v sha256sum >/dev/null; then
  sha="$(sha256sum "$tmp/$asset" | cut -d' ' -f1)"
else
  sha="$(shasum -a 256 "$tmp/$asset" | cut -d' ' -f1)"
fi
if [[ -n "$api_sha" && "$api_sha" != "$sha" ]]; then
  note "Downloaded sha256 $sha does not match the release digest $api_sha; refusing."; exit 1
fi

if [[ "$version" == "$current_version" && "$sha" == "$current_sha" ]]; then
  note "Cask already at $version ($sha)."; finish false
fi

sed -i.bak -E \
  -e "s/^  version \"[^\"]+\"$/  version \"$version\"/" \
  -e "s/^  sha256 \"[0-9a-f]{64}\"$/  sha256 \"$sha\"/" \
  "$CASK"
rm -f "$CASK.bak"
grep -qx "  version \"$version\"" "$CASK" && grep -qx "  sha256 \"$sha\"" "$CASK" || {
  note "Rewrite of $CASK failed."; exit 1
}
note "Updated $CASK: $current_version -> $version, sha256 $sha"
finish true "$version"
