# Actions are user scripts that add custom functionality to the page generation.

function actions
{
    local actionsDir="$1"

    if [ -e "$actionsDir" ]; then
        echo "Running actions in \"$actionsDir\"."
        for action in "$actionsDir"/*; do
            file="$action"
            echo "  Running \"$file\"."
            startDir="$(pwd)"
            $file | sed 's/^/    /g'
            cd "$startDir"
        done
    else
        echo "No actions in \"$actionsDir\"."
    fi
}
