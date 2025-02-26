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
app [Model, init!, respond!] { 
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
import ${platform_alias}.Http exposing [Request, Response]
import ${platform_alias}.Utc

# Model is produced by `init`.
Model : {}

# With `init` you can set up a database connection once at server startup,
# generate css by running `tailwindcss`,...
# In this case we don't have anything to initialize, so it is just `Ok({})`.
init! : {} => Result Model []
init! = |{}| Ok({})

respond! : Request, Model => Result Response [ServerErr Str]_
respond! = |req, _|
    # Log request datetime, method and url
    datetime = Utc.to_iso_8601(Utc.now!({}))

    Stdout.line!("${datetime} ${Inspect.to_str(req.method)} ${req.uri}")?

    Ok(
        {
            status: 200,
            headers: [],
            body: Str.to_utf8("<b>Hello from server</b></br>"),
        },
    )

EOL