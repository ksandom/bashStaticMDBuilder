# Processing of documents for output.

function getDocAttribute
{
    local fileName="$1"
    local attribute="$2"
    local default="$3"

    data="$(grep "<!-- $attribute: " "$fileName" | sed 's/^.*<!-- //g;s/ -->$//g' | cut -d\  -f2-)"

    if [ "$data" != '' ]; then # We have the declaration.
        echo "$data"
    else
        case "$default" in
            "") # No default, and no declaration. Complain.
                echo "Didn't get any value for document attribute '$attribute' in $fileName ($(pwd))." >&2
            ;;
            '-') # We don't need anything. Just output nothing.
                echo
            ;;
            *) # We have a default. Fall back to that.
                echo "$default"
            ;;
        esac
    fi
}

function shouldPublish
{
    # Figure out if we should publish a doc. If testing mode is turned on (--test), then yes. Otherwise it depends on whether we have met the pub date.

    if [ "$doTest" -eq 1 ]; then
        return 0
    else
        local pubDate="$(echo "$1" | sed 's/-//g')"
        local public="$2"
        local myTag="$3"

        echo -n "shouldPublish/$myTag: now=$now date=$pubDate public=$public toTest=$doTest result="
        if [ "$now" -ge "$pubDate" ] && [ "$public" == '1' ]; then
            result=0
        else
            result=1
        fi

        echo "$result"
        return "$result"
    fi
}

function prepDocs
{
    cd build
    mkdir -p ../intermediate/{rss,html,suggested,tags,tagCombos,preview,list,feed,tagBar/tags,tagBar/bars,related} rss
    echo "Prep."
    threads _buildDoc "Prep"
}

function buildDocs
{
    cd build
    echo "Build."
    threads _buildDoc "Build"
}

function _buildDoc
{
    local fileIn="$1"
    local stage="$2"
    local justTheFolder="$(basename "$(dirname "$fileIn")")"
    local isPrimary="true"

    if [ "$(basename "$fileIn")" != 'README.md' ]; then
        isPrimary="false"
    fi

    if [ "$justTheFolder" == '.' ]; then
        justTheFolder='welcome'
    fi

    # TODO Fix this upstream.
    if [ "${fileIn::12}" == 'intermediate' ]; then
        srcFile="../$fileIn"
        fileIn="$justTheFolder/README.md"
    else
        srcFile="../src/site/$fileIn"
    fi

    if [ -e "$srcFile" ]; then
        # Prep
        assertDir "$fileIn"
        fileOut="$(getOutName "$fileIn")"

        [ "$doDebug" -gt 0 ] && echo "$stage doc $fileOut."

        # Get the document attributes.
        releaseDate="$(getDocAttribute "$srcFile" 'releaseDate')"
        public="$(getDocAttribute "$srcFile" 'public')"

        if shouldPublish "$releaseDate" "$public" "$justTheFolder"; then
            myTag="$(getDocAttribute "$srcFile" 'myTag')"
            intermediateID="$myTag"
            tags="$(getDocAttribute "$srcFile" 'tags'),$myTag"
            tighterTags="$(echo "$tags" | sed 's/, /,/g')"
            uniqueTags="$(getUniqueTags "$tighterTags")"
            title="$(getDocAttribute "$srcFile" 'title')"
            titleImage="$(getDocAttribute "$srcFile" 'titleImage')"
            titleImageThumbnail="$(getImageName "$titleImage" "_thumb")"
            preview=''
            [ -e "../intermediate/preview/$myTag" ] && preview="$(cat "../intermediate/preview/$myTag")"
            description="$(getDocAttribute "$srcFile" 'description' "${preview}")"
            showInLatest="$(getDocAttribute "$srcFile" 'showInLatest' 'true')"
            showRelated="$(getDocAttribute "$srcFile" 'showRelated' 'true')"
            showInAll="$(getDocAttribute "$srcFile" 'showInAll' 'true')"
            justHideIt="$(getDocAttribute "$srcFile" 'justHideIt' 'false')"

            imagesTag="$myTag"
            if [ "$(basename "$fileIn")" != 'README.me' ]; then
                imagesTag="$justTheFolder"
            fi

            if [ "$justHideIt" == 'true' ]; then
                showInLatest="false"
                showRelated="false"
                showInAll="false"
            fi

            # TODO Make it optional to override mask on a page-by-page basis.


            postDir="../src/site/$justTheFolder"
            if [ "${titleImage::1}" == '/' ]; then
                titleImagePath="../src/site$titleImage"
                titleImageSrc="$postDir/..$titleImage"
            else
                titleImagePath="../src/site/$justTheFolder/$titleImage"
                titleImageSrc="$postDir/$titleImage"
            fi

            titleImageAbsolutePath="/$justTheFolder/titleImage.png"
            titleImageThumbnailPath="/$justTheFolder/thumbImage.png"

            # maskImage in mask out
            if [ "$titleImage" != 'whoops.jpg' ]; then
                maskImage "$titleImagePath" "../intermediate/masks/$titleSize/$mask" "$justTheFolder/titleImage.png" "$titleSize"
                maskImage "$titleImagePath" "../intermediate/masks/$thumbnailSize/$thumbMask" "$justTheFolder/thumbImage.png" "$thumbnailSize"
            else
                echo "TODO titleImage has not yet been set for $myTag."
            fi

            case "$stage" in
                "Prep")
                    # Build intermediate stuff.
                    if [ "$isPrimary" == "true" ]; then
                        local all=",all"

                        if [ "$showInAll" != 'true' ]; then
                            all=''
                        fi

                        if [ "$showInLatest" == 'true' ]; then
                            addDocToTags "$myTag" "$releaseDate" "$uniqueTags,$myTag$all,latestContender,sitemap"
                        else
                            addDocToTags "$myTag" "$releaseDate" "$uniqueTags,$myTag$all,sitemap"
                        fi
                    fi

                    saveTagCombo "$uniqueTags"
                    if [ "${description:0:1}" == '.' ] || [ "$description" == '' ]; then
                        buildPreview "$srcFile" "../intermediate/preview/$myTag"
                    else
                        echo "$description" > "../intermediate/preview/$myTag"
                    fi
                    buildItem "$myTag" "html" "$uniqueTags" "$titleImageThumbnailPath"
                    buildItem "$myTag" "rss" "$uniqueTags"
                    # TODO Remove this.
                    #makeThumbnail "$titleImagePath" ".$titleImageThumbnailPath"
                ;;
                "Build")
                    # Build the doc.
                    mkdir -p ../intermediate/almostBuilt
                    cat ../src/templates/head.html > "$fileOut"

                    cat "$srcFile" | videos | images "$imagesTag" | pandoc -p -f markdown -t html --wrap=none | indentedHeadings "$intermediateID" > ../intermediate/almostBuilt/"$intermediateID"

                    cat ../intermediate/almostBuilt/"$intermediateID" | insertTOC "$intermediateID" >> "$fileOut"

                    templateFile "$fileOut"

                    if [ -e ../src/templates/bellyButton.html  ]; then
                        cat ../src/templates/bellyButton.html >> "$fileOut"
                    fi

                    if [ "$showRelated" == 'true' ]; then
                        openDiv "recommendedItems" >> "$fileOut"

                        openDiv "myTags" "  " >> "$fileOut"
                        getTagBar "$uniqueTags" "html" >> "$fileOut"
                        closeDiv "myTags" "  " >> "$fileOut"

                        if postReferences "$myTag" "$uniqueTags"; then
                            openDiv "postReferences" "  " >> "$fileOut"
                            heading 2 "This post references" >> "$fileOut"
                            cat "../intermediate/list/$myTag.references" >> "$fileOut"
                            closeDiv "postReferences" "  " >> "$fileOut"
                        fi

                        if postReferencedBy "$myTag" "$uniqueTags"; then
                            openDiv "postReferencedBy" "  " >> "$fileOut"
                            heading 2 "This post is referenced by" >> "$fileOut"
                            cat "../intermediate/list/$myTag.postReferencedBy" >> "$fileOut"
                            closeDiv "postReferencedBy" "  " >> "$fileOut"
                        fi

                        openDiv "sameTags" "  " >> "$fileOut"
                        heading 2 "Posts using the same tags" >> "$fileOut"
                        cat "../intermediate/list/$uniqueTags" >> "$fileOut"
                        closeDiv "sameTags" "  " >> "$fileOut"

                        closeDiv "recommendedItems" >> "$fileOut"
                    fi

                    cat ../src/templates/foot.html >> "$fileOut"

                    # Highlight the tags that this post uses.
                    highlightTag "$myTag" "tagMine" "$fileOut"
                    spacedTags="$(echo "$uniqueTags" | sed 's/,/ /g')"
                    for tagToHighlight in $spacedTags; do
                        highlightTag "$tagToHighlight" "tagSame" "$fileOut"
                    done
                ;;
            esac
        else
            echo "Not publishing \"$srcFile\"."
        fi
    else
        echo "Could not find \"$srcFile\" during $stage."
    fi
}

function replaceLine
{
    local fileName="$1"
    local search="$2"
    local replace="$3"

    if [ -e "$fileName" ]; then
        rm -f "$fileName.replace"
        touch "$fileName.replace"
        while IFS= read -r line; do
            if ! echo "$line" | grep -q "$search"; then
                echo "$line" >> "$fileName.replace"
            else
                echo "$replace" >> "$fileName.replace"
            fi
        done < <(cat "$fileName")

        rm "$fileName"
        mv "$fileName.replace" "$fileName"
    fi
}

function buildPreview
{
    local inFile="$1"
    local outFile="$2"

    echo "$(grep -v '\(^<!-- \|^$\|^#\|^!\|^\[\|^----\|^====\|^\\\\\|^.$\|^http\)' "$inFile"| tr ' ' '\n' | head -n "$previewLength" | sed 's/[<>/]//g' | onlyWords)..." > "$outFile"
}

function onlyWords
{
    local words="$1"

    while read word; do
        if [ "${word:0:1}" == '[' ]; then
            out="$(echo $word | sed 's/\[//g;s/].*$//g')"
        elif [[ "$word" =~ .*\]\(.* ]]; then
            out="$(echo $word | sed 's/].*$//g')"
        else
            out="$word"
        fi

        echo -n "$out "
    done
}

function indentedHeadings
{
    local name="$1"

    mkdir -p ../intermediate/toc
    local tocFile="../intermediate/toc/$name"
    local lastIndentation=2
    local listBegun=0

    rm -f "$tocFile"

    while IFS= read -r line; do
        if [ "${line::3}" == '<hr' ] || [ "${line::3}" == '<HR' ]; then
            echo "$line"
        elif [ "${line::2}" == '<h' ] || [ "${line::2}" == '<H' ]; then
            if [ "$listBegun" == "0" ]; then
                listBegun=1
                echo "<UL>" >> "$tocFile"
            fi

            let indentLevel="${line:2:1}"
            id="$(echo "$line" | cut -d \" -f2)"
            text="$(echo "$line" | cut -d '>' -f2 | cut -d '<' -f1)"

            handleIndentationChange "$indentLevel" "$lastIndentation"

            lastIndentation="$indentLevel"

            echo -e "</SPAN>\n$line\n<SPAN CLASS=\"indentLevel$indentLevel\">"
            echo "<LI><A HREF=\"#$id\">$text</A></LI>" >> "$tocFile"
        elif [ "${line::8}" == '<!-- TOC' ]; then
            if [ "$listBegun" == "0" ]; then
                listBegun=1
                echo "<UL>" >> "$tocFile"
            fi
            let indentLevel=2
            handleIndentationChange "$indentLevel" "$lastIndentation"
            lastIndentation="$indentLevel"

            echo "<LI><A HREF=\"#table-of-contents\">Table of contents</A></LI>" >> "$tocFile"
            echo "$line"
        else
            echo "$line"
        fi
    done

    for i in $(bash -c "echo {$lastIndentation..2}"); do
        echo "</UL>" >> "$tocFile"
    done
}

function handleIndentationChange
{
    local iLevel="$1"
    local iLastILevel="$2"

    if [ "$iLevel" -lt "$iLastILevel" ]; then
        for i in $(bash -c "echo {$iLastILevel..$iLevel}" | cut -d \  -f2-); do
            echo "</UL>" >> "$tocFile"
        done
    elif [ "$iLevel" -gt "$iLastILevel" ]; then
        for i in $(bash -c "echo {$iLastILevel..$iLevel}" | cut -d \  -f2-); do
            echo "<UL>" >> "$tocFile"
        done
    fi
}

function insertTOC
{
    ## This relies on indentedHeadings to have been called first.
    local name="$1"
    local tocFile="../intermediate/toc/$name"

    while IFS= read -r line; do
        if [ "${line}" == '<!-- TOC -->' ]; then
            line="<H2 id=\"table-of-contents\">Table of contents</H2>"
            echo -e "</SPAN>\n$line\n<SPAN CLASS=\"indentLevel2\">"
            cat "$tocFile"
        else
            echo "$line"
        fi
    done
}
