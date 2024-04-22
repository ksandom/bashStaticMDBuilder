# Build items that get listed as related documents at the end of each document.

function buildItem
{
    # This is assumed to be run within prep/build so will be in the ./build directory.
    local tag="$1"
    local type="$2"
    local tags="$3"
    local thumbnail="$4"
    local itemFileOut="../intermediate/$type/$tag"
    local tagBar="$(getTagBar "$uniqueTags" "html")"
    local content="$(cat "../intermediate/preview/$tag")"

    cat "../src/templates/item.$type" | templatePipe > "$itemFileOut"

    replaceLine "$itemFileOut" '~!itemTags!~' "$tagBar"
}

