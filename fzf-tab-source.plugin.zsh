0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"
0=":A"  # Resolve to absolute physical path

function () {
  # Resolve dir to physical path immediately
  local dir=${${1:h}:A} config_directory
  
  # Use N glob qualifier to prevent errors when no matches are found
  local sources=(${dir}/sources/*.zsh(N:A))  # Added (N) qualifier
  
  # Resolve config directory symlinks too
  zstyle -s ':fzf-tab:sources' config-directory config_directory
  if [[ -n $config_directory ]]; then
    config_directory=${config_directory:A}
    sources+=(${config_directory}/**/*.zsh(.N:A))  # .N was already here
  fi

  # enable $group
  zstyle ':completion:*:descriptions' format %d

  local src line arr ctx flags
  for src in $sources; do
    [[ -f $src ]] || continue  # Skip if file doesn't exist
    
    while read -r line; do
      arr=(${(@s. .)line##\# })
      ctx=${arr[1]}
      if [[ $ctx == ':fzf-tab:'* ]]; then
        break
      fi
    done < $src
    
    # Store resolved physical paths in zstyle
    zstyle $ctx fzf-preview "src="\""${src:A}"\"" . "\""${dir:A}"\""/functions/main.zsh"
    flags=${arr[2]}
    
    if [[ -n $flags ]]; then
      zstyle $ctx fzf-flags $flags
    fi
  done
} $0