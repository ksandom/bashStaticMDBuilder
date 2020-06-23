# Actions

For when you need to do something special in a build.

## Using it

Create a script in either `src/actions/build-pre` or `src/actions/build-post`.

Here's an example called `legacyRSS` in `src/actions/build-post`

```bash
#!/bin/bash
# Provide a mechanism for the old RSS feeds.

mkdir -p build/legacyRSS
cp build/rss/all.rss build/legacyRSS/index.html
```

## Running it

Any scripts you have put in these directories will automatically get run at the appropriate time in the build process.

* `src/actions/build-pre` - Before any build work has begun.
* `src/actions/build-post`.- After all other build tasks have finished.

It looks like this when there is nothing to do

```
No actions in "src/actions/build-pre".
```

Or this when there is something to do

```
Running actions in "src/actions/build-post".
  Running "src/actions/build-post/legacyRSS".
```
