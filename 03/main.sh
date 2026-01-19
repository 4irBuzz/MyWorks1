#!/bin/bash

source output.sh

if [ $parameter -eq 1 ]; then
    log_remove
elif [ $parameter -eq 2 ]; then
    dt_remove
else
    nm_remove
fi