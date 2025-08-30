package citro.util;

import citro.backend.CitroTween;
import citro.object.CitroObject;

/**
 * Cool objects utility for making new styles.
 */
class CitroObjectUtil {
    /**
     * Tweens by fading the sprite and destroys it when done. Use this if you want to fix an exception if you're destroying the sprite while tween's active.
     * @param obj Object to fade out as.
     * @param time Time in seconds to fade and destroy.
     */
    public static function fadeAndDestroy(obj:CitroObject, time:Float) {
        var objRef:CitroObject = untyped __cpp__('obj');
        
        CitroTween.tween(objRef, [{
            variableToUse: ALPHA,
            destination: 0
        }], time, LINEAR, () -> {
            // Crash prevention (reflaxe.cpp you're so cool for turning obj != null to true...)
            if (untyped __cpp__('objRef != nullptr') && !objRef.isDestroyed) {
                objRef.destroy();
            }
        });
    }
}