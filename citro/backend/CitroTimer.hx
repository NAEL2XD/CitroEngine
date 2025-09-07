package citro.backend;

import cxx.std.ios.IStream;

@:headerCode('
#include <limits>
#include <3ds.h>
#include "citro_CitroInit.h"
')

private typedef TimerMetadata = {
    oldTime:Float,
    ms:Int,
    onComplete:Void->Void,
    loopsLeft:Int,
    ranInState:Bool
}

/**
 * Class for timer handlers and for callbacks.
 */
class CitroTimer {
    public static var timers:Array<TimerMetadata> = [];

    /**
     * Creates a new timer specified from arguments provided.
     * @param seconds The current total of seconds to use.
     * @param onComplete Callback function to use.
     * @param loops How many loops do you wanna use? 0 or less = Infinite.
     */
    public static function start(seconds:Float, onComplete:Void->Void, loops:Int = 1) {
        timers.push({
            oldTime: seconds,
            ms: Std.int(seconds * 1000),
            onComplete: onComplete,
            loopsLeft: loops <= 0 ? untyped __cpp__('std::numeric_limits<int>::max()') : loops,
            ranInState: !CitroG.isNotNull(CitroInit.subState)
        });
    }

    /**
     * Should not be used.
     */
    public static function update(delta:Int) {
        if (timers.length == 0) {
            return;
        }

        var i:Int = 0;
        while (i < timers.length) {
            var timer = timers[i];
            if (timer.ranInState == CitroG.isNotNull(CitroInit.subState)) {
                i++;
                continue;
            }

            timer.ms -= delta;

            if (timer.ms <= 0) {
                timer.onComplete();
                timer.loopsLeft--;
                timer.ms = Std.int(timer.oldTime * 1000);

                if (timer.loopsLeft < 1) {
                    timers.splice(i, 1);
                    continue;
                }
            }

            i++;
        }
    }
}