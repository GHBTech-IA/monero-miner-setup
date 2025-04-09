#!/bin/bash

watch -n 5 'ps -C xmrig -o pid,pcpu,pmem,etime --sort=-pcpu | head -n 10'

