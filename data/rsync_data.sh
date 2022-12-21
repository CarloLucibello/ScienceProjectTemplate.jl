#!/bin/bash

# This script is used to rsync data from the server to the local machine

REMOTE=europa  # The name of the remote machine in your .ssh/config file
REMOTE_DIR="~/Git/ScienceProjectTemplate.jl/data/raw"

rsync -avz $REMOTE:$REMOTE_DIR ./
