package citro.util;

import citro.backend.CitroTween;
import citro.object.CitroObject;

/**
 * Cool objects utility for making new styles.
 */
class CitroObjectUtil {
    /**
     * Tweens by fading the sprite.
     * @param obj Object to fade out as.
     * @param time Time in seconds to fade.
     */
    public static function fade(obj:CitroObject, time:Float) {
        var objRef:CitroObject = untyped __cpp__('obj');
        
        CitroTween.tween(objRef, [{
            variableToUse: ALPHA,
            destination: 0
        }], time, LINEAR);
    }
}