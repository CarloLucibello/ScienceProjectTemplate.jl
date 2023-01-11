#!/bin/bash

# This script is used to rsync data from the server to the local machine

REMOTE=europa  # The name of the remote machine in your .ssh/config file
REMOTE_DIR="~/Git/ScienceProjectTemplate.jl/data/raw"

rsync -avz $REMOTE:$REMOTE_DIR ./


## TWO WAYS SYNC 
## Notice that the data is not deleted from the local machine
REMOTE=bidsa  # The name of the remote machine in your .ssh/config file
REMOTE_DIR="~/Git/Benchmarks_SAT/benchmarks"
rsync -avz $REMOTE:$REMOTE_DIR ../ --include='*.csv' --include='*/' --exclude='*'
echo "Sync from remote machine $REMOTE to local machine terminated."
read -n 1 -s -r -p "--> Press any key to proceed with sync from local to remote or kill with Crl+C."
rsync -avz --delete ./ $REMOTE:$REMOTE_DIR --include='*.csv' --include='*/' --exclude='*'
