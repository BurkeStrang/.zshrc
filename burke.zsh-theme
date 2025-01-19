# Minimal oh-my-posh style Zsh theme featuring context, path, git integration, 
# success/failure hearts, and segmented colors.

# Color and symbol definitions
CURRENT_BG='NONE'
CURRENT_FG='20b2aa'
SEGMENT_SEPARATOR=$'\ue0b0'
SUCCESS_HEART='\ue23a'
FAILURE_HEART='\ue23a'
LEFT_ROUNDED_CORNER="\ue0b6"
RIGHT_ROUNDED_CORNER="\ue0b4"

prompt_segment() {
  local bg fg content decoration
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  [[ -n $4 ]] && decoration=$4 || decoration=""
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n "%{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%}"
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n "$decoration$3"
}

prompt_context() {
  prompt_segment '#1A1F24' '#20b2aa' " %n "
}

prompt_path() {
  prompt_segment '#2C3E50' '#20b2aa' " \uea83 %1~ "
}

prompt_git() {

  local gitbackgroundcolor="#3B3B64"

  (( $+commands[git] )) || return
  if [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    return
  fi
  if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ]]; then
    return
  fi

  local repo_path ref dirty mode
  repo_path="$(git rev-parse --git-dir 2>/dev/null)"
  parse_git_dirty() { [[ -n "$(git status --porcelain 2>/dev/null)" ]] && echo "*"; }
  dirty="$(parse_git_dirty)"
  ref="$(git symbolic-ref HEAD 2>/dev/null)" || \
       ref="◈ $(git describe --exact-match --tags HEAD 2>/dev/null)" || \
       ref="➦ $(git rev-parse --short HEAD 2>/dev/null)"

  local PL_BRANCH_CHAR=$'\ue0a0'
  local ahead behind
  ahead="$(git log --oneline @{upstream}.. 2>/dev/null)"
  behind="$(git log --oneline ..@{upstream} 2>/dev/null)"
  if [[ -n "$ahead" && -n "$behind" ]]; then
    PL_BRANCH_CHAR=$'\u21c5'
  elif [[ -n "$ahead" ]]; then
    PL_BRANCH_CHAR=$'\u21b1'
  elif [[ -n "$behind" ]]; then
    PL_BRANCH_CHAR=$'\u21b0'
  fi

  if [[ -e "${repo_path}/BISECT_LOG" ]]; then
    mode=" <B>"
  elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
    mode=" >M<"
  elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
    mode=" >R>"
  fi

  local content="${${ref:gs/%/%%}/refs\/heads\//$PL_BRANCH_CHAR }${mode}"
  [[ -n "$dirty" ]] && content="${content} ${dirty}"

  if [[ -n "$dirty" ]]; then
    prompt_segment $gitbackgroundcolor "blue" " $content"
  else
    prompt_segment $gitbackgroundcolor "#20b2aa" " $content "
  fi
}

prompt_status() {
  if [[ $RETVAL -ne 0 ]]; then
    prompt_segment '#1E3A5F' '#ff79c6' " $FAILURE_HEART "
  else
    prompt_segment '#1E3A5F' '#20b2aa' " $SUCCESS_HEART "
  fi
}

build_prompt() {
  RETVAL=$?
  echo -n "%K{NONE}%F{#1A1F24}$LEFT_ROUNDED_CORNER%f%k"
  prompt_context
  prompt_path
  prompt_git
  prompt_status
  echo -n "%K{NONE}%F{#1E3A5F}$RIGHT_ROUNDED_CORNER%f%k"
  # echo -n "%F{#20b2aa}"
  echo -n "%f%k"
}

PROMPT='%{%f%b%k%}$(build_prompt) '
