# :fzf-tab:complete:((\\|*/|)aws):*

local prefix="${words% *}"
local cmd="$prefix $word"

local global_options=(
  --debug
  --endpoint-url
  --no-verify-ssl
  --no-paginate
  --output
  --query
  --profile
  --region
  --version
  --color
  --no-sign-request
  --ca-bundle
  --cli-read-timeout
  --cli-connect-timeout
  --cli-binary-format
  --no-cli-pager
  --cli-auto-prompt
  --no-cli-auto-prompt
)

if [[ $word == "-"* ]]; then
  # Preview only works for the first option, because it's a hard to parse the command without options
  if [[ $prefix == *"--"* ]]; then
    return
  fi

  if [[ $global_options[*] =~ "$word" ]]; then

    echo "\$ aws help"
    aws help | head -n 150 | rg -A10 -- "$word"

    printf "\n%s:\n  " "For more information, run"
    echo "$prefix help | less --pattern=$word"

    if [[ $prefix != aws ]]; then
      printf "or:\n  "
      echo "aws help | less --pattern=$word"
    fi
  else
    cmd_help=$(eval "$prefix help")
    options_line=$(echo $cmd_help | rg --stop-on-nonmatch --color=never "OPTIONS" --line-number | awk -F ':' '{print $1}')

    echo "\$ $prefix help"
    echo $cmd_help | tail -n +$options_line | rg -A10 -- "$word"

    printf "\n%s:\n  " "For more information, run"
    echo "$prefix help | less --pattern=$word" | bat -pl bash
  fi

  return
fi

if bash -c "tldr aws $word" >/dev/null 2>&1; then
  echo "$ tldr aws $word"
  tldr --color=always aws $word | tail -n +3
fi

echo "$ $cmd help"
eval "$cmd help"