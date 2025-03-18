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

# Generate the file header with new format
cat > "$file_name" << EOL
app [test_cases, config] { 
    ${platform_alias}: platform "${platform_url}"
EOL

# Process remaining arguments in pairs and add package entries
while [ $# -gt 0 ]; do
    package_alias="$1"
    package_url="$2"
    echo "    ${package_alias}: \"${package_url}\"," >> "$file_name"
    shift 2
done

# Add the closing part and rest of the template
cat >> "$file_name" << EOL
}

# =========================================================
# IMPORTANT! This version of roc-start is deprecated.
# To continue recieving script (plugin) updates, please
# update to the latest version of roc-start.
# =========================================================

import ${platform_alias}.Test exposing [test]
import ${platform_alias}.Config
import ${platform_alias}.Debug
import ${platform_alias}.Browser
import ${platform_alias}.Element
import ${platform_alias}.Assert

config = Config.default_config

test_cases = [test1]

test1 = test(
    "use roc repl",
    |browser|
        # go to roc-lang.org
        browser |> Browser.navigate_to!("http://roc-lang.org")?
        # find repl input
        repl_input = browser |> Browser.find_element!(Css("#source-input"))?
        # wait for the repl to initialize
        Debug.wait!(200)
        # send keys to repl
        repl_input |> Element.input_text!("0.1+0.2{enter}")?
        # find repl output element
        output_el = browser |> Browser.find_element!(Css(".output"))?
        # get output text
        output_text = output_el |> Element.get_text!?
        # assert text - fail for demo purpose
        output_text |> Assert.should_be("0.3000000001 : Frac *"),
)
EOL
