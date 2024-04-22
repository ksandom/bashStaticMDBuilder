# References at the end of each document.

function postReferences
{
    local myTag="$1"
    local tags="$2"

    cd ..
    IFS=","
    result=0
    mkdir -p "intermediate/postReferences"
    rm -f "intermediate/postReferences/$myTag.references"

    for tag in $tags; do
        if [ "$tag" != "$myTag" ] && [ "$tag" != "welcome" ]; then
            if [ -e "src/site/$tag" ]; then
                echo "unimportantDate $tag" >> "intermediate/postReferences/$myTag.references"
                let result=$result+1
            fi
        fi
    done
    IFS=" "

    if [ "$result" -gt 0 ]; then
        echo "$myTag.references" | buildList intermediate/postReferences html intermediate/list 100000
        cd ~-
        return 0
    else
        cd ~-
        return 1
    fi
}

function postReferencedBy
{
    local myTag="$1"
    local tags="$2"

    cd ..
    IFS=","
    result=0
    mkdir -p "intermediate/postReferencedBy"
    rm -f "intermediate/postReferencedBy/$myTag.postReferencedBy"

    if grep -v " \($myTag\|welcome\)$" "intermediate/tags/$myTag" >> "intermediate/postReferencedBy/$myTag.postReferencedBy"; then
        IFS=" "
        echo "$myTag.postReferencedBy" | buildList intermediate/postReferencedBy html intermediate/list 100000
        cd ~-
        return 0
    else
        IFS=" "
        cd ~-
        return 1
    fi
}

function generateRelated
{
    # This is assumed to be called from inside intermediate/tags
    local tag="$1"
    local outputDir="../related/$tag"
    local outputFile="$outputDir/README.md"

    if [ ! -e "$outputFile" ]; then
        mkdir -p "$outputDir"
        cat "../../src/templates/relatedTag.md" | sed "s#~!myTag!~#$tag#g" > "$outputFile"
    fi
}
