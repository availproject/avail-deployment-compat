#!/bin/bash

set -e

# env needed
# OP_DEVICE=pdnqef4mfiapdz3mvvuu7c4zfe
# OP_SECRET_KEY

op account add --address polygontechnology.1password.com --email victor@polygon.technology
eval $(echo $OP_MASTER_PASSWORD | op signin)
