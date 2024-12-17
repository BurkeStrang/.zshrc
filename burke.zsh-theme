# vim:ft=zsh ts=2 sw=2 sts=2
#
# Adapted Oh My Posh-style Zsh Theme

# Colors and symbols
CURRENT_BG='NONE'
CURRENT_FG='20b2aa'
SEGMENT_SEPARATOR=$'\ue0b0'  # 

# Heart symbols for success and failure
SUCCESS_HEART='\ue23a'  # Anatomical Heart (Greenish for success)
FAILURE_HEART='\ue23a'  # Anatomical Heart (Red for failure)

# Begin a segment
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

# End the prompt
# prompt_end() {
#   echo -n "%{%k%}"
#   CURRENT_BG='black'
#   CURRENT_FG='green'  # Ensure foreground color is reset at the end
# }

# Prompt components
prompt_context() {
  prompt_segment '#1A1F24' '#20b2aa' " %n "  # Changed from '#00CCCC' to '#20b2aa'
}

prompt_path() {
  prompt_segment '#2C3E50' '#20b2aa' " \uea83 %1~ "
}

prompt_git() {
  local branch dirty remote_icon ahead behind
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  dirty=$(git status --porcelain 2>/dev/null | wc -l)
  
  if [[ -n $branch ]]; then
    # # Determine the remote repository URL
    # remote_url=$(git config --get remote.origin.url)
    #
    # # Set remote icon based on the remote URL
    # if [[ $remote_url =~ github\.com ]]; then
    #   remote_icon="\ue7a1"  # GitHub
    # elif [[ $remote_url =~ azure\.com ]]; then
    #   remote_icon="\ue7a2"  # Azure DevOps
    # else
      remote_icon=""   # Generic Remote Icon
    # fi
    
    # Fetch commit counts ahead and behind
    # Ensure we have a remote to compare with
    if git rev-parse --verify origin/"$branch" >/dev/null 2>&1; then
      ahead=$(git rev-list --count "$branch"@{upstream}..HEAD 2>/dev/null)
      behind=$(git rev-list --count HEAD.."$branch"@{upstream} 2>/dev/null)
    else
      ahead=0
      behind=0
    fi

    # Construct the commit status string
    commit_status=""
    if [[ $ahead -gt 0 && $behind -gt 0 ]]; then
      # Both ahead and behind are greater than zero; concatenate without space
      commit_status+="↑$ahead↓$behind"
    else
      # Handle cases where only one of them is greater than zero
      if [[ $ahead -gt 0 ]]; then
        commit_status+="↑$ahead"
      fi
      if [[ $behind -gt 0 ]]; then
        commit_status+="↓$behind"
      fi
    fi

    # Append uncommitted changes indicator
    if [[ $dirty -gt 0 ]]; then
      commit_status+="✚"
    fi

    # Final prompt segment
    prompt_segment '#2A2A6F' '#20b2aa' " $remote_icon$branch $commit_status "  # Changed from '#4caf50' to '#20b2aa'
  fi
}

prompt_status() {
  if [[ $RETVAL -ne 0 ]]; then
    prompt_segment '#1E3A5F' '#ff79c6' " $FAILURE_HEART "  # No change (failure remains pink)
  else
    prompt_segment '#1E3A5F' '#20b2aa' " $SUCCESS_HEART "  # Changed from '#4caf50' to '#20b2aa'
  fi
}

# Rounded corner characters
LEFT_ROUNDED_CORNER="\ue0b6"  # 
RIGHT_ROUNDED_CORNER="\ue0b4" # 

build_prompt() {
  RETVAL=$?

  # Set background to NONE and use the left rounded corner with the initial color
  echo -n "%K{NONE}%F{#1A1F24}$LEFT_ROUNDED_CORNER%f%k"  # Changed foreground from '#4C6B70' to '#1A1F24'

  prompt_context
  prompt_path
  prompt_git
  prompt_status

  # Set background to NONE and use the right rounded corner with the final color
  echo -n "%K{NONE}%F{#1E3A5F}$RIGHT_ROUNDED_CORNER%f%k"  # No change

  echo -n "%F{#20b2aa}"  # Changed from '%F{green}' to '%F{#20b2aa}'
}

# Set the PROMPT
PROMPT='%{%f%b%k%}$(build_prompt) '

# Removed execution time prompt objects
