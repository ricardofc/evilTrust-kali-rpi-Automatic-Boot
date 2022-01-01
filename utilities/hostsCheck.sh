#!/bin/bash

for i in $(seq 1 254); do
	timeout 1 bash -c "ping -c 1 172.16.31.$i" > /dev/null 2>&1 && echo "Host 172.16.31.$i - ACTIVE" &
done; wait
