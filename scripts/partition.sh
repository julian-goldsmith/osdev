#!/bin/bash
sfdisk $1 < scripts/partitions.sfdisk
exit 0
