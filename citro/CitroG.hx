package citro;

import cxx.num.UInt32;
import citro.backend.CitroTween;
import citro.backend.CitroTimer;
import citro.state.CitroState;
import citro.math.CitroRandom;
import haxe3ds.HID;
import haxe3ds.HID.TouchPosition;
import citro.object.CitroObject;

@:cppFileCode("
#include <3ds.h>
#include <string.h>
")

/**
 * Class for current stuff like overlapping and straight up stuff.
 */
class CitroG {
    /**
     * Sound implementation.
     */
    public static var sound:CitroSoundG = new CitroSoundG();

    /**
     * Current width for the Top 3DS Screen.
     */
    public static var width(default, null):Int = 400;

    /**
     * Current height for the Top and Bottom 3DS Screen.
     */
    public static var height(default, null):Int = 240;

    /**
     * Current width for the Bottom 3DS Screen
     */
    public static var widthBottom(default, null):Int = 240;

    /**
     * Variable for random management.
     */
    public static var random:CitroRandom = new CitroRandom();

    /**
     * Checks if both sprites are overlapping.
     * @param obj1 First object to use as.
     * @param obj2 Second object to use as.
     * @return true if both are overlapping, false if not overlapping or one of the object is invisible.
     */
    public static function overlaps(obj1:CitroObject, obj2:CitroObject):Bool {
        if (!obj1.visible || !obj2.visible) {
            return false;
        }

        return obj1.x < obj2.x + (obj2.width * Math.abs(obj2.scale.x)) &&
               obj1.x + (obj1.width * Math.abs(obj1.scale.x)) > obj2.x &&
               obj1.y < obj2.y + (obj2.height * Math.abs(obj2.scale.y)) &&
               obj1.y + (obj1.height * Math.abs(obj1.scale.y)) > obj2.y;
    }

    /**
     * Checks whetever if object is being touched/held in the bottom screen.
     * @param obj The object to use and check.
     * @return true if currently touching, false if not touching or not in bottom screen. Note that it always returns true if sprite's x and y is in 0 and in bottom, so i suggest you move to somewhere else.
     */
    public static function isTouching(obj:CitroObject):Bool {
        if (!obj.bottom || !obj.visible) {
            return false;
        }

        final t:TouchPosition = HID.touchPadRead();
        return (obj.x < t.px) && (obj.x + (obj.width * obj.scale.x) > t.px) && (obj.y < t.py) && (obj.y + (obj.height * obj.scale.y) > t.py);
    }

    /**
     * Opens an URL using the 3DS's Internet Browser method.
     * 
     * #### Note:
     * 
     * This file is COPIED from this url: https://gitlab.com/3ds-netpass/netpass/-/blob/main/source/utils.c?ref_type=heads#L395-L409
     * 
     * @param url The url to open as.
     */
    public static function openURL(url:String) {
        untyped __cpp__('
            if (url == "NULL") {
                aptLaunchSystemApplet(APPID_WEB, 0, 0, 0);
                return;
            }
            size_t url_len = strlen(url.c_str()) + 1;
            if (url_len > 1024) return openURL("NULL");
            size_t buffer_size = url_len + 1;
            u8* buffer = (u8*)malloc(buffer_size);
            if (!buffer) return openURL("NULL");
            memcpy(buffer, url.c_str(), url_len);
            buffer[url_len] = 0;
            aptLaunchSystemApplet(APPID_WEB, buffer, buffer_size, 0);
        ');
    }

    /**
     * Switches to a new state and destroys the current state.
     * 
     * ### Warning:
     * Switching states quickly will likely THROW AN EXCEPTION!!
     * 
     * @param state The new state to switch.
     */
    public static function switchState(state:CitroState) {
        CitroTimer.timers = [];
        CitroTween.cta = [];

        CitroInit.curState.destroy();
        CitroInit.curState = state;
        CitroInit.callCreate = true;
    }

    /**
     * Quits CitroInit and the other state and de-initializes other citro functions.
     */
    public static function exitGame() {
        CitroInit.shouldQuit = true;
        if (untyped __cpp__('citro::CitroInit::subState != nullptr || citro::CitroInit::subState != NULL')) CitroInit.subState.close();
        CitroInit.curState.destroy();
    }
}

class CitroSoundG {
    public function new() {}

    /**
     * Current storage for sounds running from fastPlaySound
     */
    public var storedSounds:Map<String, CitroSound> = [];

    /**
     * Plays a sound fast without using CitroSound class, will automatically be stored to a map.
     * @param soundPath Sound Path found in romfs, don't include `romfs:/`.
     * @param stopNow Should stop if sound is currently playing?
     */
    public function play(soundPath:String, stopNow:Bool = false) {
        if (storedSounds.exists(soundPath)) {
            storedSounds.get(soundPath).play(stopNow);
            return;
        }

        var snd:CitroSound = new CitroSound(soundPath);
        storedSounds.set(soundPath, snd);
        snd.play();
    }

    /**
     * Stops a sound fast without using CitroSound class.
     * 
     * Will do nothing if it doesn't exist.
     */
    public function stop(soundPath:String) {
        if (storedSounds.exists(soundPath)) {
            storedSounds.get(soundPath).pause();
        }
    }

    /**
     * Loads a sound and stores from file, recommended because switching states won't kill the sound.
     * 
     * Upon loading sound, it will be stored in `storedSounds`
     * 
     * @param soundPath Current path to sound found in `romfs:/`, don't include the prefix.
     * @param store Whetever or not if you wanna store in `storedSounds`?
     * @return CitroSound loaded.
     */
    public function load(soundPath:String, store:Bool = true):CitroSound {
        return storedSounds.exists(soundPath) ? storedSounds.get(soundPath) : {
            var snd:CitroSound = new CitroSound(soundPath);
            if (store) storedSounds.set(soundPath, snd);
            snd;
        }
    }

    /**
     * Precaches a sound that can be used later.
     * @param soundPath Sound path to use, do not include the `romfs:/` prefix since it does that for you.
     */
    public function precache(soundPath:String) {
        if (storedSounds.exists(soundPath)) {
            return;
        }

        var snd:CitroSound = new CitroSound(soundPath);
        storedSounds.set(soundPath, snd);
    }
}