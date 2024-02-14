#!/bin/zsh
for name in $(terraform state list | grep -E "vault|newrelic"); do terraform state rm $name; done