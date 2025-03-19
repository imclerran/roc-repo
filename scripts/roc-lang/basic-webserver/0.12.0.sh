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

# Generate the file
cat > "$file_name" << EOL
app [Model, init!, respond!] { 
    ${platform_alias}: platform "${platform_url}",
EOL

# Process remaining arguments in pairs and add package entries directly
while [ $# -gt 0 ]; do
    package_alias="$1"
    package_url="$2"
    echo "    ${package_alias}: \"${package_url}\"," >> "$file_name"
    shift 2
done

# Add the closing part
cat >> "$file_name" << EOL
}

# =========================================================
# IMPORTANT! This version of roc-start is deprecated.
# To continue recieving script (plugin) updates, please
# update to the latest version of roc-start.
# =========================================================

import ${platform_alias}.Stdout
import ${platform_alias}.Http exposing [Request, Response]
import ${platform_alias}.Utc

EOL

cat >> "$file_name" << 'EOL'

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

    "${datetime} ${Inspect.to_str(req.method)} ${req.uri}" |> Stdout.line!?

    Ok(
        {
            status: 200,
            headers: [],
            body: "<b>Hello from server</b></br>" |> Str.to_utf8,
        },
    )

EOL
