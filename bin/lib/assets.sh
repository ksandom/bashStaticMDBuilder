# Asset management.

function copyAssets
{
    for asset in img js css; do
        if [ -e "src/site/$asset" ]; then
            echo "Copying $asset."
            rsync -r "src/site/$asset" build/ &
        else
            echo "Skipping $asset."
        fi
    done

    wait
}

function findSubAssets
{
    cd src/site
    find | grep -v '\(/$\|.md$\)' | cut -b3-
}

function copySubAssets
{
    cd build
    while read fileIn; do
        mkdir -p "$(dirname "$fileIn")"
        if [ ! -d "../src/site/$fileIn" ]; then
            cp "../src/site/$fileIn" "$fileIn"
        fi
    done
}

function findSymlinks
{
    cd src/site
    find . -type l | cut -b3-
    cd .. # TODO Is this really needed?
}

function copySymlinks
{
    cd build
    echo "Copying symlinks."
    while read -r symlink; do
        subDir="$(dirname "$symlink")"
        if [ "$subDir" != '.' ]; then
            mkdir -p "$subDir"
        fi

        if [ ! -f "$symlink" ]; then
            cp -P "../src/site/$symlink" "$symlink"
        fi
    done
}
