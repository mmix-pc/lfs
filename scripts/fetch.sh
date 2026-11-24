#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit

source "$(dirname "$0")/paths.sh"
mkdir -p "$DOWNLOADS_DIR"/{archives,git,locks} "$BUILD_DIR/sources"

# The lock covers creation, object transfer and publication of the pinned ref.
cache_git() (
    local source=$1 revision=$2 key repo stage
    [[ $revision =~ ^[0-9a-f]{40}$ ]] || { echo "Expected a pinned commit: $revision" >&2; exit 1; }
    key=$(printf '%s' "$source" | sha256sum | cut -d' ' -f1)
    repo="$DOWNLOADS_DIR/git/$key.git"
    exec 9>"$DOWNLOADS_DIR/locks/git-$key"
    flock 9

    if [[ ! -d $repo ]]; then
        stage=$(mktemp -d "$DOWNLOADS_DIR/git/.new.XXXXXX")
        trap 'rm -rf -- "$stage"' EXIT
        git init -q --bare "$stage"
        git -C "$stage" remote add origin "$source"
        mv -T "$stage" "$repo"
        trap - EXIT
    fi

    if ! git -C "$repo" show-ref --verify --quiet "refs/pins/$revision"; then
        git -C "$repo" fetch --no-tags origin "$revision:refs/pins/$revision" >&2
    fi
    printf '%s\n' "$repo"
)

checkout_git() {
    local repo=$1 dest=$2 revision=$3 upstream=$4
    if [[ ! -d $dest/.git ]]; then
        git init -q "$dest"
    fi
    if [[ -n $(git -C "$dest" status --porcelain --untracked-files=no) ]]; then
        echo "Tracked changes in $dest" >&2
        return 1
    fi
    git -C "$dest" fetch --no-tags "$repo" "refs/pins/$revision"
    git -C "$dest" checkout --detach "$revision"

    if git -C "$dest" remote get-url origin >/dev/null 2>&1; then
        git -C "$dest" remote set-url origin "$upstream"
    else
        git -C "$dest" remote add origin "$upstream"
    fi
}

cache_archive() (
    local source=$1 checksum=$2 dest part
    [[ $checksum =~ ^[0-9a-f]{32}$ ]]
    dest="$DOWNLOADS_DIR/archives/$checksum/${source##*/}"
    exec 9>"$DOWNLOADS_DIR/locks/archive-$checksum"
    flock 9

    if [[ -f $dest ]] && printf '%s  %s\n' "$checksum" "$dest" | md5sum -c --status; then
        return
    fi
    mkdir -p "${dest%/*}"
    part=$(mktemp "$dest.XXXXXX")
    trap 'rm -f "$part"' EXIT
    curl -fL "$source" -o "$part"
    printf '%s  %s\n' "$checksum" "$part" | md5sum -c -
    mv -T "$part" "$dest"
)

for manifest in manifests/{tools,lfs-packages}.tsv; do
    while IFS=$'\t' read -r name kind source revision; do
        case "$kind" in
            kind) continue ;;
            git)
                repo=$(cache_git "$source" "$revision")
                checkout_git "$repo" "$BUILD_DIR/sources/$name" "$revision" "$source"
                ;;
            archive) cache_archive "$source" "$revision" ;;
            *) echo "Unknown source kind: $kind" >&2; exit 1 ;;
        esac
    done < "$manifest"
done

# Let Meson apply QEMU's wrap patches while sourcing Git objects from the cache.
cd "$BUILD_DIR/sources/qemu"
wraps=(keycodemapdb dtc berkeley-softfloat-3 berkeley-testfloat-3)
export GIT_CONFIG_COUNT=${GIT_CONFIG_COUNT:-0}
for name in "${wraps[@]}"; do
    wrap="subprojects/$name.wrap"
    fields=$(python3 - "$wrap" <<'PYWRAP'
import configparser
import sys

wrap = configparser.ConfigParser(interpolation=None)
with open(sys.argv[1]) as stream:
    wrap.read_file(stream)
print(wrap["wrap-git"]["url"], wrap["wrap-git"]["revision"], sep="\t")
PYWRAP
    )
    IFS=$'\t' read -r source revision <<< "$fields"
    repo=$(cache_git "$source" "$revision")
    export "GIT_CONFIG_KEY_$GIT_CONFIG_COUNT=url.$repo.insteadOf"
    export "GIT_CONFIG_VALUE_$GIT_CONFIG_COUNT=$source"
    GIT_CONFIG_COUNT=$((GIT_CONFIG_COUNT + 1))
done
meson subprojects download "${wraps[@]}"
