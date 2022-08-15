#!/bin/bash

defaultPipeline="pipeline"
defaultBranch="main"

pipelineJsonCopy="pipeline-$(date +'%m-%d-%Y').json"

## Colors
red=$'\e[1;31m'
grn=$'\e[1;32m'
end=$'\e[0m'

## Check if jq is installed
checkJQ() {
  type jq >/dev/null 2>/dev/null
  checkJqResult=$? # $? is the result

  if [ "$checkJqResult" -ne 0 ]; then
    printf "  ${red}'jq' not found! (json parser)\n${end}"
    printf "  MacOS Installation: brew install jq\n"
    printf "  Ubuntu Installation: sudo apt install jq\n"
    exit 1
  else
    printf "  ${grn}'jq' found!\n${end}"
  fi
}

## Check if the first param was provided. It should be a path to the pipeline.json.
checkFirstParam() {
  local command=$1
  ## -z tests if the expansion of "$1" is a null string
  if [[ -z $command ]]; then
    echo "No path to the pipeline definition JSON file is provided!"
    exit 1
  fi
}

pipelineJson=$1;
echo "Pipeline.json path: $pipelineJson"

shift # https://unix.stackexchange.com/questions/140840/using-getopts-to-parse-options-after-a-non-option-argument

## Get the options (only short ones)
while getopts b:c:o:p option; do # no ":" means no argument after the flag
   case $option in
      b) branch=$OPTARG;;
      c) configuration=$OPTARG;;
      o) owner=$OPTARG;;
      p) pollForSourceChanges=true;;
      \?) # Invalid option
        echo "Error: Invalid option"
        exit;;
   esac
done

echo "Branch: $branch"
echo "Configuration: $configuration"
echo "Owner: $owner"
echo "PollForSourceChanges: $pollForSourceChanges"

## Perform checks
checkJQ
checkFirstParam $pipelineJson

## Copy json
cat $pipelineJson > $pipelineJsonCopy

echo "Removing metadata..."
jq 'del(.metadata)' "$pipelineJsonCopy" > tmp.$$.json && mv tmp.$$.json "$pipelineJsonCopy"

echo "Incrementing version..."
jq '.pipeline.version +=1' "$pipelineJsonCopy" > tmp.json && mv tmp.json "$pipelineJsonCopy"

## Perform only metadata delete and version upgrade if there is only one param provided.
if [ "$#" -eq "1" ]; then
  exit 0
fi

echo "Updating the Branch..."
jq --arg a "$branch" '.[].stages[0].actions[0].configuration.Branch = $a' $pipelineJsonCopy > tmp.json && mv tmp.json "$pipelineJsonCopy"

echo "Updating the Owner..."
jq --arg a "$owner" '.[].stages[0].actions[0].configuration.Owner = $a' $pipelineJsonCopy > tmp.json && mv tmp.json "$pipelineJsonCopy"

echo "Updating the PollForSourceChanges..."
jq --arg a "$pollForSourceChanges" '.[].stages[0].actions[0].configuration.PollForSourceChanges = $a' $pipelineJsonCopy > tmp.json && mv tmp.json "$pipelineJsonCopy"

exit 0
