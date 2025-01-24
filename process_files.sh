#!/bin/bash

while IFS= read -r file; do
    dir=$(dirname "$file")
    base=$(basename "$file")
    new_name=$(echo "$base" | sed "s/_[0-9]\{12\}//")
    mkdir -p "lib/$dir"
    cp "lib_backup/$file" "lib/$dir/$new_name"
    echo "Moved $file to lib/$dir/$new_name"
done < latest_files.txt