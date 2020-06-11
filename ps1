#!/bin/bash

[[ -z ${BASHRC_CONFIG_PS1_USE_GIT_BRANCH} ]] && export BASHRC_CONFIG_PS1_USE_GIT_BRANCH=1
[[ -z ${BASHRC_CONFIG_PS1_SHOW_DELTA_TIME} ]] && export BASHRC_CONFIG_PS1_SHOW_DELTA_TIME=1

function ansii_escape {
    echo "\033[$*"
}

function ps1_escape {
    echo "\[$(ansii_escape $*)\]"
}

function print_color {
    local name="$1"
    local bgfg="$2"
    local bright="$3"
    local color_1=3
    local color_2=7
    [[ ${bright} -eq 1 ]] || bright=0
    case "${name}" in
        black)   color_2=0             ;;
        red)     color_2=1             ;;
        green)   color_2=2             ;;
        brown)   color_2=3             ;;
        yellow)  color_2=3  ; bright=1 ;;
        blue)    color_2=6             ;;
        magenta) color_2=5             ;;
        cyan)    color_2=3             ;;
        white)   color_2=7  ; bright=1 ;;
        reset)   echo "00m" ; return 0 ;;
        gray)
            if [[ ${bright} -eq 0 ]]; then
                color_2=0
                bright=1
            else
                color_2=7
                bright=0
            fi
        ;;
        *) echo "$0: ${name}: expected color" >&2 ; return 1 ;;
    esac
    if [[ "${bgfg}" = "bg" ]]; then
        color_1=4
    elif [[ "${bgfg}" = "fg" ]]; then
        color_1=3
    else
        echo "$0: ${bgfg}: expected bg or fg" >&2
        return 1
    fi
    echo "${bright};${color_1}${color_2}m"
    return 0
}

function ansii_escape_color {
    ansii_escape "$(print_color $*)"
}

function ps1_escape_color {
    ps1_escape "$(print_color $*)"
}

export COLOR_BLUE=$(ps1_escape_color    "blue"    "fg")
export COLOR_CYAN=$(ps1_escape_color    "cyan"    "fg" 1)
export COLOR_GREEN=$(ps1_escape_color   "green"   "fg" 1)
export COLOR_RED=$(ps1_escape_color     "red"     "fg")
export COLOR_BROWN=$(ps1_escape_color   "brown"   "fg")
export COLOR_MAGENTA=$(ps1_escape_color "magenta" "fg" 1)
export COLOR_RESET=$(ps1_escape_color   "reset")

function get_branch {
	git branch 2>/dev/null | grep \* | tr -d '* '
}

function get_status {
    local git_status=$(git status --porcelain)
    local new_files=$(echo -e "${git_status}" | grep '?? ' | wc -l)
    local add_files=$(echo -e "${git_status}" | grep 'A  ' | wc -l)
    local del_files=$(echo -e "${git_status}" | grep 'D  ' | wc -l)
    local ad_files=$(echo -e "${git_status}" | grep 'AD ' | wc -l)
    if [[ $new_files -gt 0 ]] || [[ $del_files -gt 0 ]] || [[ $ad_files -gt 0 ]]; then
        echo '*'
    elif [[ $add_files -gt 0 ]]; then
	echo '+'
    fi
}

function ps1_function {
    local status=$?
    local curr_time=$(date +%s)
    local time_delta=
    if [[ $BASHRC_CONFIG_PS1_SHOW_DELTA_TIME -eq 1 ]]; then
        [[ "${PS1_PREV_TIME}" = "" ]] || [[ ${PS1_PREV_TIME} -eq 0 ]] && PS1_PREV_TIME=${curr_time}
        time_delta=$[curr_time - ${PS1_PREV_TIME}]
        export PS1_PREV_TIME=${curr_time}
    fi

    local user_color=$(if [[ $EUID -eq 0 ]]; then echo "${COLOR_RED}"; else echo "${COLOR_GREEN}"; fi)
    local prompt_color=$(if [[ ${status} -eq 0 ]]; then echo "${COLOR_GREEN}"; else echo "${COLOR_RED}"; fi)
    local git_branch=
    if [[ $BASHRC_CONFIG_PS1_USE_GIT_BRANCH -eq 1 ]]; then
        git_branch=$(get_branch)
        if [[ "${git_branch}" != "" ]]; then
            git_branch="${COLOR_RESET}(${COLOR_CYAN}${git_branch}$(get_status ${git_branch})${COLOR_RESET})"
        fi
    fi

    local working_dir="${COLOR_BROWN}\w${COLOR_RESET}"
    curr_time="${COLOR_MAGENTA}$(date '+%T.%3N')"
    [[ $BASHRC_CONFIG_PS1_SHOW_DELTA_TIME -eq 1 ]] && time_delta="${COLOR_RESET}(${COLOR_RED}${time_delta}s${COLOR_RESET})"
    local user_host="${user_color}\u${COLOR_RESET}@${COLOR_BLUE}\h"
    local prompt="${prompt_color}\$${COLOR_RESET}"

    export PS1="${working_dir} ${git_branch}\n${curr_time} ${time_delta} ${user_host} ${prompt} "
}

PROMPT_COMMAND="ps1_function"
