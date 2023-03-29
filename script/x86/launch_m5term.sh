#!/bin/bash

CAPCOM_GEM5_M5OUT="./zz_launch_baremetal/m5out"

echo "Opening m5term ..."

PORT_NUM=$(grep -oP '(?<=Listening for connections on port )[0-9]+' $CAPCOM_GEM5_M5OUT/simerr)

m5term $PORT_NUM

echo "Closing..."