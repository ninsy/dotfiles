#!/bin/bash

limit=20
results=()

commit_hashes=$(git rev-list master)
for commit_hash in $commit_hashes; do
    config_version=$(git show $commit_hash:config-version 2>/dev/null)
    commit_tag=$(git describe --tags --exact-match $commit_hash 2>/dev/null)
  
    if [ $? -eq 0 ]; then
        if [ -z "$commit_tag" ]; then
            #   continue
            results+=("$commit_hash: $config_version (no tag)") 
        else
            results+=("$commit_hash: $config_version (tag: $commit_tag)") 
        fi
    else
        continue
        # echo "$commit_hash: (no config-version file)"
    fi
  
    if [ ${#results[@]} -ge $limit ]; then
        break
    fi
done

for result in "${results[@]}"; do
  echo "$result"
done