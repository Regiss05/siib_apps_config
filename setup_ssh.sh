#!/bin/bash

# Get email from git config or prompt user
EMAIL=$(git config --global user.email)
if [ -z "$EMAIL" ]; then
  read -p "Enter your email for SSH key: " EMAIL
fi

# Generate SSH key if not exists
if [ ! -f ~/.ssh/id_rsa ]; then
  ssh-keygen -t rsa -b 4096 -C "$EMAIL" -N "" -f ~/.ssh/id_rsa
fi

# Copy the key to the remote server
ssh-copy-id administrator@93.127.134.81