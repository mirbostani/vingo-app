# Vingo

A study helper application.

## Features

### v1.0.4

- Keyboard Shortcuts (Desktop)

### v1.0.3

- Decks List

### v1.0.2

- SQLite Database
- Deck

### v1.0.1

- Custom Font (Roboto)
- About Dialog & License Page

### v1.0.0

- Pages (Home, Settings, etc.)
- Localization & Translation (`en_US`, `fa_IR`, etc.)
- Light and Dark Themes
- Font Resizing

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