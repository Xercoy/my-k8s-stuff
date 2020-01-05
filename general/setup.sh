#!/bin/bash

sudo apt-get update
sudo apt-get install -y emacs

# add bash completion and alias for a better life
echo 'alias k="kubectl "' >> ~/.bashrc
echo 'source $(kubectl completion bash)'