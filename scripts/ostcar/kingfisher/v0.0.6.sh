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
app [init_model, update_model, handle_request!, Model] { 
    ${platform_alias}: platform "${platform_url}",
EOL

# Add package entries
for ((i=0; i<${#package_aliases[@]}; i++)); do
    echo "    ${package_aliases[i]}: \"${package_urls[i]}\"," >> "$file_name"
done

# Add the closing part
cat >> "$file_name" << EOL
}

import ${platform_alias}.Http

Model : Str

init_model = "World"

update_model : Model, List (List U8) -> Result Model _
update_model = |model, event_list|
    event_list
    |> List.walk_try(
        model,
        |_acc_model, event|
            Str.from_utf8(event)
            |> Result.map_err(|_| InvalidEvent),
    )

handle_request! : Http.Request, Model => Result Http.Response _
handle_request! = |request, model|
    when request.method is
        Get ->
            Ok(
                {
                    body: Str.to_utf8("Hello ${model}\n"),
                    headers: [],
                    status: 200,
                },
            )

        Post(save_event!) ->
            event =
                if List.is_empty(request.body) then
                    Str.to_utf8("World")
                else
                    when Str.from_utf8(request.body) is
                        Ok(_) -> request.body
                        Err(_) ->
                            return Err(InvalidBody)

            save_event!(event)

            new_model = update_model(model, [event])?
            Ok(
                {
                    body: Str.to_utf8(new_model),
                    headers: [],
                    status: 200,
                },
            )

        _ ->
            Err(MethodNotAllowed(Http.method_to_str(request.method)))

EOL