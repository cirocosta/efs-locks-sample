#!/bin/bash

# Performs the mounting of an EFS mount target into
# predefined MOUNT_LOCATION in the filesystem.

set -o errexit

readonly MOUNT_LOCATION="${MOUNT_LOCATION:-/mnt/efs}"
readonly MOUNT_TARGET="${MOUNT_TARGET}"

# Main routine - checks for the MOUNT_TARGET variable
# that does not have a default (can be empty) making
# sure that it gets specified.
main() {
  if [[ -z "$MOUNT_TARGET" ]]; then
    echo 'ERROR:
  MOUNT_TARGET environent variable must be specified.
    '
    exit 1
  fi

  echo "INFO:
  Mounting shared filesystem.

  MOUNT_LOCATION  $MOUNT_LOCATION
  MOUNT_TARGET    $MOUNT_TARGET
  "

  mount_nfs
}

# Performs the actual mounting of the EFS target
# in the AZ we specified into a directory we defined
# via MOUNT_LOCATION.
mount_nfs() {
  sudo mkdir -p $MOUNT_LOCATION

  sudo mount \
    -t nfs4 \
    -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 \
    $MOUNT_TARGET:/ $MOUNT_LOCATION
}

main
