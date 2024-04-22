# Threading functionality.

## Use like this:
# function threadTester
# {
#     echo "  $1"
#     sleep 1
# }
#
# ls -1 /dev | threads threadTester
#
# This runs the 1 threadTester function in its own thread for every directory entry in /dev.

function cpuCores
{
    grep '^processor.*:' /proc/cpuinfo | wc -l
}

# Default settings that can be overridden in the app's config.
maxThreads="$(cpuCores)"
threadPoolDir="/tmp/threadPool-$$"
threadPoolInterval="0.5"

function prepareThreadPool
{
    mkdir -p "$threadPoolDir"
}

function cleanUpThreadPool
{
    rm -Rf "$threadPoolDir"
}

function getThreadCount
{
    ls -1 "$threadPoolDir/" | wc -l
}

function capacityAvailable
{
    local threadCount="$(getThreadCount)"
    if [ "$threadCount" -lt "$maxThreads" ]; then
        return 0
    else
        return 1
    fi
}

function threadsStillRunning
{
    if [ "$(getThreadCount)" -gt "0" ]; then
        return 0
    else
        return 1
    fi
}

function threads
{
    local functionToRun="$1"
    prepareThreadPool

    echo "Starting threadPoolDir=$threadPoolDir maxThreads=$maxThreads threadPoolInterval=$threadPoolInterval"

    local stuffToDo=1
    local itemCount=0
    while [ "$stuffToDo" -eq 1 ]; do
        if capacityAvailable; then
            if read -r input; then
                thread "$functionToRun" "$input" "$2" "$3" "$4" "$5" "$6" "$7" "$8" &
                let itemCount=$itemCount+1
            else
                if threadsStillRunning; then
                    sleep "$threadPoolInterval"
                else
                    stuffToDo=0
                fi
            fi
        else
            sleep "$threadPoolInterval"
        fi
    done

    echo "Finished threadPoolDir=$threadPoolDir itemCount=$itemCount"

    cleanUpThreadPool
}

function thread
{
    local functionToRun="$1"
    local input="$2"
    threadID="$(echo "$functionToRun $input $3 $4 $5 $6 $7 $8 $9 $$" | md5sum | cut -d\  -f1)"
    local lockFile="$threadPoolDir/$threadID"

    echo "Thread: $functionToRun/$threadID \"$input\" \"$3\" \"$4\" \"$5\" \"$6\" \"$7\" \"$8\" \"$9\""

    date > "$lockFile"
    "$functionToRun" "$input" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
    rm -f "$lockFile"
}

function cpuCoresMinus
{
    let cores="$(cpuCores)"-"$1"
    if [ "$cores" -lt 1 ]; then
        cores=1
    fi

    echo "$cores"
}

function cpuCoresPlus
{
    let cores="$(cpuCores)"+"$1"
    echo "$cores"
}

function halfCPUCores
{
    let cores="$(cpuCores)"/2
    if [ "$cores" -lt 1 ]; then
        cores=1
    fi

    echo "$cores"
}
