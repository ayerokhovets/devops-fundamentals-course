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

pipelineJson=$1

## Perform checks
checkJQ
checkFirstParam $pipelineJson

## Copy json
cat $pipelineJson > $pipelineJsonCopy

## Remove metadata
echo "Removing metadata..."
jq 'del(.metadata)' "$pipelineJsonCopy" > tmp.$$.json && mv tmp.$$.json "$pipelineJsonCopy"
## Increment version
echo "Incrementing version..."
jq '.pipeline.version +=1' "$pipelineJsonCopy" > tmp.json && mv tmp.json "$pipelineJsonCopy"

## Perform only metadata delete and version upgrade if there is only one param provided.
if [ "$#" -eq "1" ]; then
  exit 0
fi

## Get the options (only short ones)
while getopts b:c:o: option; do
   case $option in
      b) branch=$OPTARG;; # Branch
      c) configuration=$OPTARG;; # Configuration
      o) owner=$OPTARG;; # Owner
      \?) # Invalid option
        echo "Error: Invalid option"
        exit;;
   esac
done

echo "Branch: $branch"
echo "Configuration: $configuration"
echo "Owner: $owner"

exit 0
