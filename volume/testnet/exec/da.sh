#!/bin/sh
cat /entrypoint.sh;

trap cleanup 1 2 3 6

cleanup()
{
  echo "Done cleanup ... quitting."
  exit 1
}

/da/bin/data-avail $@
