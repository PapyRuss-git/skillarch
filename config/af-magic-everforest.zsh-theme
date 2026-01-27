# af-magic-everforest.zsh-theme
#
# Based on af-magic by Andy Fleming
# Customized with Everforest Hard Dark colors
#

# dashed separator size
function afmagic_dashes {
  # check either virtualenv or condaenv variables
  local python_env_dir="${VIRTUAL_ENV:-$CONDA_DEFAULT_ENV}"
  local python_env="${python_env_dir##*/}"

  # if there is a python virtual environment and it is displayed in
  # the prompt, account for it when returning the number of dashes
  if [[ -n "$python_env" && "$PS1" = *\(${python_env}\)* ]]; then
    echo $(( COLUMNS - ${#python_env} - 3 ))
  elif [[ -n "$VIRTUAL_ENV_PROMPT" && "$PS1" = *${VIRTUAL_ENV_PROMPT}* ]]; then
    echo $(( COLUMNS - ${#VIRTUAL_ENV_PROMPT} - 3 ))
  else
    echo $COLUMNS
  fi
}

# Everforest Hard Dark colors using standard zsh codes
local everforest_fg="%F{white}"            # Primary text
local everforest_dim="%F{240}"             # Dimmed text (dark grey)
local everforest_green="%F{green}"         # Accent green
local everforest_aqua="%F{cyan}"           # Accent aqua
local everforest_blue="%F{blue}"           # Accent blue
local everforest_purple="%F{magenta}"      # Accent purple
local everforest_orange="%F{214}"          # Warning/dirty (orange)
local everforest_yellow="%F{yellow}"       # Info/status
local everforest_red="%F{red}"             # Error/critical
local reset="%{$reset_color%}"

# primary prompt: dashed separator, directory and vcs info
PS1="${everforest_dim}\${(l.\$(afmagic_dashes)..-.)}${reset}
${everforest_yellow}%~\$(git_prompt_info)\$(hg_prompt_info) ${everforest_purple}%(!.#.»)${reset} "
PS2="${everforest_orange}\ ${reset}"

# right prompt: return code, virtualenv and context (user@host)
RPS1="%(?..${everforest_red}%? ↵${reset})"
if (( $+functions[virtualenv_prompt_info] )); then
  RPS1+='$(virtualenv_prompt_info)'
fi
RPS1+=" ${everforest_dim}%n@%m${reset}"

# git settings
ZSH_THEME_GIT_PROMPT_PREFIX=" ${everforest_dim}(${everforest_green}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY="${everforest_orange}*${reset}"
ZSH_THEME_GIT_PROMPT_SUFFIX="${everforest_dim})${reset}"

# hg settings
ZSH_THEME_HG_PROMPT_PREFIX=" ${everforest_dim}(${everforest_green}"
ZSH_THEME_HG_PROMPT_CLEAN=""
ZSH_THEME_HG_PROMPT_DIRTY="${everforest_orange}*${reset}"
ZSH_THEME_HG_PROMPT_SUFFIX="${everforest_dim})${reset}"

# virtualenv settings
ZSH_THEME_VIRTUALENV_PREFIX=" ${everforest_purple}["
ZSH_THEME_VIRTUALENV_SUFFIX="]${reset}"