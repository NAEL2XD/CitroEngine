<p align="center">
  <a href="https://github.com/NAEL2XD/Haxe3DS">
    <img src="logo.png" alt="Haxe3DS" width="600">
  </a>
</p>

A HaxeFlixel based library meant for making 3ds games easily.

> [!WARNING] 
> This is still in a work in progress, bugs and such can be encountered, if you have found any bugs make sure to report it in the issues tab.

## How does this work?

This uses [Haxe3DS](https://github.com/NAEL2XD/Haxe3DS), [citro2d](https://github.com/devkitPro/citro2d) and [citro3d](https://github.com/devkitPro/citro3d) for it to make everything work, some extra functions are taken from [HaxeFlixel](https://haxeflixel.com/) since it's suppose to be based on that.

## What does it contain:

It contains a large variety of stuff that was included.

Currently it supports those at this time:
- States
- Substates
- Sounds (can be played multiple times)
- Objects (Text and Sprite)
- Tweens
- Timers

## Installation

Do the following tutorial from [Haxe3DS](https://github.com/NAEL2XD/Haxe3DS#installation) first, then come back here.

1. Assuming you've followed the haxe3ds tutorial, open up CMD and type `(dkp-)pacman -S 3ds-dev 3ds-portlibs` and install them (the dkp- is for linux based only)
2. Assuming you have setup the project with your haxelib created, type `haxelib git https://github.com/NAEL2XD/CitroEngine`, it should install this to your project.
3. In your `3dsSettings.json`, push `citroEngine` in `settings.libraries`.
4. Go to the `example` folder and copy to your project so that you'll be working on them later.
5. For the moment of truth, type `python build.py -c`, it should compile and launch it!