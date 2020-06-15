# bashStaticMDBuilder

## Introduction

Yet another static site from markdown builder. This one is written in bash.

Key features include

* Generates HTML from markdown.
* Resizes your images to sizes you specify in the config, and creates thumbnails.
* Uses templates so you can format your site the way your want.
* Supports scheduled posts.
* Provides testing functionality
    * Test CSS without having to rebuild.
    * See future posts to make sure they look as you expect.
* Generates RSS for
    * Everything (/rss/all.rss)
    * Individuallly for every tag. Ie Visitors can subscribe to a specific tag if they want to. That way they can get alerted by just the stuff they want to see.
* Handles the upload to your bucket (currently S3 only).

## Requirements

* pandoc
* imagemagick
* rsync
* bash
* python

## Installation

**NOTE: that these steps will change. Please check back here for the current instructions.**

Clone the repo somewhere.
```bash
git clone https://github.com/ksandom/bashStaticMDBuilder.git
```

Seed your new project.
```bash
mkdir myAwesomeWebsite
cd myAwesomeWebsite
/path/to/bashStaticMDBuilder/bin/seed
```

After you have run this, you will be able to reference all availale scripts with `./bin/` in front. For example, `./bin/build`.

Make sure to edit the file `config` before trying to build the site.

## Using it

### Creating a new post

Let's create a post called "example".
```bash
./bin/new example
myTag="example" postDir="src/site/example" file="src/site/example/README.md".
```

That created a new directory in `src/site` called `example`. Inside that, it created `README.md`, which will later resolve to `index.html`.
You can now edit `src/site/example/README.md` in your favourite editor. It has created some important variables at the top of that `README.md`. These are inside comments, so will not be displayed in the final output, but will affect aspects of the output.

```html
<!-- myTag: example -->
<!-- public: 1 -->
<!-- releaseDate: 2020-06-15 -->
<!-- tags: whoops -->
<!-- title: Example -->
<!-- titleImage: whoops.jpg -->
```

* `myTag` should be unique, and match the directory name. Assumptions will break if it doesn't.
* `public` if you want to hide a post that has been released, but don't want to delete it. Set this to `0`. Otherwise, it should be `1`. You can also use this if you don't know when you will be ready to release it
* `releaseDate` on this date, it will be included when you run `./bin/build` or `./bin/freshBuild`.
* `tags` is a comma separated list of tags for the page. Eg `hardware, phone, durability`.
* `title` is the human readable text describes the page in few words. Eg "How to make an example page".
* `titleImage` is the image to load that gives this page a sense of personalisation. Eg `example.jpg`. You can prefix it with an absolute path like `/images/example.jpg` if you want to escape the current directory. But by default will look in the directory of the post.

### Building it

A normal build. Work will be cached, so this is the convenient command to use most of the time.
```bash
./bin/build
```

When ever you need to build from scratch, for example when you've done some testing, you can do a `./bin/freshBuild` to get a comepletely new build. It will delete and re-create the `build` and `intermediate` directories.
```bash
./bin/freshBuild
```

Any parameter that works with `./bin/build` will also work with `./bin/freshBuild`.

### Testing it

If you want to test a post that has not yet been released, you can do `--test` to show all unreleased posts. `./bin/up` will refuse to run in this state to prevent you from accidentally releasing something before you are ready. See "Uploading it" below for more information.
```bash
./bin/build --test
```

If you want to do some CSS work, you can run `./bin/testCSS`. This will create symlinks, so any changes you make to CSS will be immediately available when you refresh the page. The consequence is that this is not an uploadable state, so you will need to do a `./bin/freshBuild` when you're done to be able to upload it.
```bash
./bin/testCSS
```

### Uploading it

This assumes you have the [aws CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) installed and working and the permissions for accessing the S3 bucket for your website.

```bash
./bin/up
```

If you have used `--test` when building, or used `./bin/testCSS`, then `./bin/up` will refuse to run. You can reset this by running `./bin/freshBuild`.

`./bin/up` creates the `uploadCache` folder. This is used to present a consistent state so that the S3 upload won't re-upload stuff that hasn't changed.
