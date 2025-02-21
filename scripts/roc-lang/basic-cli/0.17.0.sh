#!/bin/bash

# Ensure at least three arguments (filename + one pair)
if (( $# < 3 )) || (( ($# - 1) % 2 != 0 )); then
    echo "Usage: $0 file_name platform_alias platform_url [package_alias1 package_url1 ...]"
    exit 1
fi

# Store the filename
file_name="$1"
shift 1

# Store the first pair as platform
platform_alias="$1"
platform_url="$2"
shift 2

# Arrays for packages
declare -a package_aliases=()
declare -a package_urls=()

# Process remaining arguments in pairs
while (( $# )); do
    package_aliases+=("$1")
    package_urls+=("$2")
    shift 2
done

# Generate the file
cat > "$file_name" << EOL
app [main] { 
    ${platform_alias}: platform "${platform_url}",
EOL

# Add package entries
for ((i=0; i<${#package_aliases[@]}; i++)); do
    echo "    ${package_aliases[i]}: \"${package_urls[i]}\"," >> "$file_name"
done

# Add the closing part
cat >> "$file_name" << EOL
}

import ${platform_alias}.Stdout

main =
    Stdout.line! "Hello, World!"
EOL