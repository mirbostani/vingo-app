# Vingo

A study helper application.

## Features

### v1.0.9+14

- Deck Stats
- Markdown Editor
- Cards List
- Card Context Menu
- Search Cards
- Search Decks
- Deck Context Menu
- Messenger
- Shortcuts
- Keyboard Shortcuts (Desktop)
- Decks List
- SQLite Database
- Deck
- Custom Font (Roboto)
- About Dialog & License Page
- Pages (Home, Settings, etc.)
- Localization & Translation (`en_US`, `fa_IR`, etc.)
- Light and Dark Themes
- Font Resizing

## Requirements

```shell
$ flutter --version
Flutter 2.6.0-6.0.pre.210 • channel master • https://github.com/flutter/flutter.git
Framework • revision 69ae50310b (41 minutes ago) • 2021-09-24 15:30:09 -0700
Engine • revision dcffd551cb
Tools • Dart 2.15.0 (build 2.15.0-144.0.dev)
```

## Add Linux Support

We should modify Flutter to be able to build Vingo as a Linux desktop application. Accordingly, we have to switch from `stable` to `master` channel, and then upgrade our Flutter installation.

```shell
$ flutter channel master
$ flutter upgrade
$ flutter doctor # diagnose required tools
```

Next, we are required to install `ninja-build` on our Linux machine. It can be downloaded from [here](https://github.com/ninja-build/ninja/releases).

```shell
$ cd ~/Downloads
$ wget -c "https://github.com/ninja-build/ninja/releases/download/v1.10.1/ninja-linux.zip"
$ unzip ninja-linux.zip
$ sudo mv ninja /usr/local/bin
$ cd /usr/local/bin
$ sudo chown root:root ninja
$ ninja --version
```

Now we have to enable Linux support:

```shell
$ cd /path/to/vingo
$ flutter precache --linux # populate tools cache
$ flutter config --enable-linux-desktop
$ flutter create . # download required packages
```

And finally, we can test by building Vingo for Linux:

```shell
$ flutter run -d linux
```