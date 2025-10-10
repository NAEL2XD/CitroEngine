package citro;

import cxx.num.UInt8;
import cxx.num.UInt64;

/**
 * Sound class that uses SDL's Mixer to play sounds and not ivorbisfile.
 * 
 * Note: If creating a new big sound, it will take ~15 seconds to initialize!
 * 
 * @since 1.0.0
 */
@:headerCode('
#include <3ds.h>
#include <tremor/ivorbisfile.h>
#include <cwav.h>
')

@:headerClassCode('
    CWAV* cwav;
    bool canPlay;
    u64 oldTime;
    u64 oldPauseTime;
')
class CitroSound {
    /**
     * Current file path read.
     */
    public var filePath(default, null):String;

    /**
     * Changes the playback speed. Default: 1.0 (no pitch change).
     */
    public var pitch(get, set):Float;
    function get_pitch():Float {
        return untyped __cpp__('cwav->pitch');
    }
    function set_pitch(pitch:Float):Float {
        untyped __cpp__('ndspChnSetRate(channel, (float)(cwav->sampleRate) * pitch2)');
        return untyped __cpp__('cwav->pitch = (float)(pitch2)');
    }

    /**
     * The current channel it's playing on.
     */
    public var channel(default, null):UInt8;

    /**
     * Whetever or not this sound should loop or not, default: false.
     */
    public var looped(get, set):Bool;
    function get_looped():Bool {
        return untyped __cpp__('cwav->isLooped == 1');
    }
    function set_looped(looped:Bool):Bool {
        return untyped __cpp__('cwav->isLooped = looped2');
    }

    /**
     * Value in the range [0.0, 1.0]. 0.0 muted and 1.0 full volume. Default: 1.0
     */
    public var volume(get, set):Float;
    function get_volume():Float {
        return untyped __cpp__('cwav->volume');
    }
    function set_volume(volume:Float):Float {
        untyped __cpp__('
            cwav->volume = (float)(volume2);

            float mix[12] = {0};
            for (int i = 0; i < 4; i++) mix[i] = (i % 2 == 0 ? 0.8f : 0.2f) * cwav->volume;
            ndspChnSetMix(channel, mix)
        ');
        return volume;
    }

    /**
     * Creates a new CWAV sound from file path and plays it for you.
     * 
     * ~~FFMPEG Command (required): `ffmpeg -i "input.wav" -ar 22050 -ac 1 -c:a libvorbis -b:a 96k "output.ogg"`~~
     * 
     * ~~Requires Audacity for this one.~~
     * 
     * You will need to have `cwavtool` downloaded from https://github.com/PabloMK7/cwavtool and both cwav and ncsnd installed. (Encoding `dspadpcm` is recommended for less size)
     * 
     * @param file File path in romfs to use as, not required to use `romfs:/`, must be as a `bcwav` extension.
     */
    public function new(file:String) {
        untyped __cpp__('
            char path[256];
            snprintf(path, 256, "romfs:/%s", file.c_str());

            this->canPlay = false;
            this->cwav = (CWAV*)malloc(sizeof(CWAV));
            cwavFileLoad(this->cwav, path, 1);

            if (cwav->loadStatus == CWAV_SUCCESS) {
                cwav->isLooped = false;
                canPlay = true;
            } else {
                cwavFileFree(cwav);
            }

            this->filePath = std::string(path);
        ');
    }

    /**
     * Plays the current loaded mixer, if sound is currently playing it will pause, no sound will play if failed (likely if sound doesn't exist or has failed).
     */
    public function play() {
        untyped __cpp__('if (this->canPlay) channel = cwavPlay(cwav, 0, -1).monoLeftChannel');
    }

    /**
     * Resumes the channel that is currently paused.
     */
    public function stop() {
        untyped __cpp__('if (this->canPlay) cwavStop(cwav, -1, -1)');
    }
    
    /**
     * Destroys the current sound and frees up memory.
     */
    public function destroy() {
        untyped __cpp__('
            if (this->canPlay) {
                cwavFileFree(cwav);
                this->canPlay = false;
            }
        ');
    }
}