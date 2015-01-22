# atgc

## Overview

Half-stealth mode, no information about this project for now :)

## Developers

### General git workflow

The main development branch is `develop`, and contains
all semi-stable (ie. that do not crash Autogica at startup) modules.

The main release branch is `master`, and contains all stable
(that are not empty, and do actual useful things) modules.

### Git workflow to create a new module:

Basically, fork the base branch and pull your dependencies.
Never work directly in develop or master. Never, ever, ever.

    $ git checkout base
    $ git checkout -b atgc-NAME-OF-MY-NEW-MODULE
    $ git pull . atgc-NAME-OF-DEPENDENCY-1
    $ git pull . atgc-NAME-OF-DEPENDENCY-N etc..
   $ git push origin atgc-NAME-OF-MY-NEW-MODULE

This way, each branch is uncluttered by the development of others.
From time to time, the `base` branch will be updated for readme update etc..


