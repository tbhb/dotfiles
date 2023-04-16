#!/bin/bash -e
op item get $ANSIBLE_OP_ITEM --vault $ANSIBLE_OP_VAULT --format json | jq -r '.fields[] | select(.id=="password").value'
