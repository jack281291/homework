#! /bin/bash
search_string=$1
cut -d',' -f13 bridges.data.version2 | grep "$search_string" | wc -l
