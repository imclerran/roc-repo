#!/usr/bin/env sh

# Ensure at least three arguments (filename + one pair)
if [ $# -lt 3 ] || [ $(($# - 1)) -lt 2 ] || [ $(($# - 1)) -gt 0 -a $(($# - 1)) -lt 2 ] || [ $((($# - 1) % 2)) -ne 0 ]; then
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

# Generate the file header
cat > "$file_name" << EOL
app [main!] { 
    ${platform_alias}: platform "${platform_url}",
EOL

# Process remaining arguments in pairs and add package entries
while [ $# -gt 0 ]; do
    package_alias="$1"
    package_url="$2"
    echo "    ${package_alias}: \"${package_url}\"," >> "$file_name"
    shift 2
done

# Add the closing part
cat >> "$file_name" << EOL
}

import ${platform_alias}.Stdout

main! = |_args|
    Stdout.line!("Hello, World!")
EOL