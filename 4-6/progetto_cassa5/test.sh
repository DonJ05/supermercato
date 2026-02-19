#!/bin/bash

cassa=$(cat cassa.log)
product=$(cat prodotti_default.csv)

if [ cassa == product ]; then
    exit 0
fi
