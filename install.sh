#!/bin/bash

name=$(basename "$0")

function show_usage
{
    cat <<EOF
Usage: $0 [options]
Options:
    -h,--help           Show this help
    -f,--force          Remove existing installation if present.
    -v,--verbose        Enable verbose logging.
    --no-git-branch     Disable git branch information in PS1 (boosts performance on slower machines).
    --no-delta-time     Disable time-delta in PS1 (boots performance on slower machines).
EOF
}

function die_usage
{
    show_usage >&2
    exit 1
}

FORCE=0
NO_GIT_BRANCH=0
NO_DELTA_TIME=0
VERBOSE=0

function echov
{
    [[ $VERBOSE -eq 1 ]] && echo $*
}

if [[ $# -gt 0 ]]; then
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)       die_usage       ;;
            -f|--force)      FORCE=1         ;;
            --no-git-branch) NO_GIT_BRANCH=1 ;;
            --no-delta-time) NO_DELTA_TIME=1 ;;
            -v|--verbose)    VERBOSE=1       ;;
            *)
                show_usage >&2
                echo "Unrecognised parameter $1" >&2
                exit 1
            ;;
        esac
        shift
    done
fi

source_uri="https://github.com/ChrisSwinchatt/BashRC.git"
target_dir=".bash"

pushd "${HOME}" >/dev/null
if [[ -d ".bash" ]]; then
    if [[ $FORCE -eq 0 ]]; then
        echo "${name}: Can't install - directory .bash already exists (try --force)" >&2
        exit 1
    fi
    rm -rf .bash
    echov "${name}: Removed directory .bash (--force)"
fi

echov "${name}: Cloning git repo"

clone_opts="-q"
#[[ "${VERBOSE}" -eq 1 ]] && clone_opts="-v"
git clone "${clone_opts}" "${source_uri}" "${target_dir}"
if [[ -f ".bashrc" ]]; then
    if [[ $FORCE -eq 0 ]]; then
        echo "${name}: Can't install - file .bashrc already exists (try --force)" >&2
        exit 1
    fi
    rm ".bashrc"
    echov "Removed existing .bashrc (--force)"
fi

ln -s "${target_dir}/.bashrc"
echov "Linked .bashrc"

[[ $NO_GIT_BRANCH -ne 0 ]] && echo "export BASHRC_CONFIG_PS1_USE_GIT_BRANCH=0"  >>"${target_dir}/env"
[[ $NO_DELTA_TIME -ne 0 ]] && echo "export BASHRC_CONFIG_PS1_SHOW_DELTA_TIME=0" >>"${target_dir}/env"
echov "Set configuration variables"

. .bashrc
echov "Loaded new .bashrc"

popd >/dev/null

echo "${name}: All done"