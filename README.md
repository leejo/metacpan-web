![test](https://github.com/metacpan/metacpan-web/workflows/test/badge.svg?branch=master)
[![Coverage Status](https://coveralls.io/repos/metacpan/metacpan-web/badge.svg)](https://coveralls.io/r/metacpan/metacpan-web)

<!-- vim-markdown-toc GFM -->

* [Getting Started](#getting-started)
    * [Installing Manually](#installing-manually)
        * [Installing on macOS](#installing-on-macos)
    * [Running Tests](#running-tests)
    * [Running the App](#running-the-app)
    * [Local Git and testing considerations](#local-git-and-testing-considerations)
    * [Local Configuration Changes](#local-configuration-changes)
    * [Compatibility Notes](#compatibility-notes)

<!-- vim-markdown-toc -->

# Getting Started

We strongly recommend using [metacpan-docker](https://github.com/metacpan/metacpan-docker).
This will give you a virtual machine already configured and ready to start developing on.

If you prefer not to use Docker, the following commands will get you started:

## Installing Manually

    carton install
    npm install
    export PATH="$(realpath ./node_modules/.bin):$PATH"

### Installing on macOS

If you like, you can install `carton` via Homebrew:

```bash
brew install carton
```

If your `carton install` is having issues with SSL-related modules, you may need to use an `OPENSSL_PREFIX`. Something like:

```bash
OPENSSL_PREFIX="/usr/local/Cellar/openssl@1.1/1.1.1q" carton install
```

You may need to check `/usr/local/Cellar/openssl@1.1` to find the latest installed path on your system.

## Running Tests

You can use the supplied wrapper around `prove` to run tests:

    ./bin/prove t

To run the tests in parallel, add `-j8` (or however many CPUs you have) to the
`prove` command.

## Running the App

```bash
carton exec plackup -p 5001 -r
```

If you'd like to use `Gazelle` rather than the default Plack server:

```bash
carton exec plackup -p 5001 -s Gazelle -r
```

## Local Git and testing considerations

You will want to set up the supplied pre-commit Git hook like so:

    ./git/setup.sh

which causes `tidyall` to be run before each commit. You can manually
run this with `tidyall path/to/file`

## Local Configuration Changes

The back end defaults to `fastapi.metacpan.org`. Running a local API server is
optional and not required to hack on the front end.  The address to the API
being used can be changed in the `metacpan_web.conf` file.  Ideally you would create a
new file called `metacpan_web_local.conf` that contains

    api                 http://127.0.0.1:5000

which will be loaded on top of the existing config file.

## Compatibility Notes

On Win32 (and possibly also on other platforms) when using Perl < 5.12, the
server started with plackup will generate warnings relating to date parsing.
These are caused by Plack due to a bug in the gmtime implementation and can be
removed by upgrading to Perl 5.12.
