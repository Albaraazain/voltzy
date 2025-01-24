#!/bin/bash

find lib -type f -name "*.dart" | while read -r file; do
    new_name=$(echo "$file" | sed "s/[0-9]\{2\}\.dart$/.dart/")
    mv "$file" "$new_name"
done