package citro.backend;

import citro.math.CitroMath;
import citro.object.CitroObject;

enum abstract CitroObjVar(Int) {
    var X;
    var Y;
    var WIDTH;
    var HEIGHT;
    var ANGLE;
    var ALPHA;
    var SCALE_X;
    var SCALE_Y;
}

enum abstract CitroEase(Int) {
    var LINEAR;
    var SINE_IN;
    var SINE_OUT;
    var SINE_INOUT;
    var QUAD_IN;
    var QUAD_OUT;
    var QUAD_INOUT;
    var CUBE_IN;
    var CUBE_OUT;
    var CUBE_INOUT;
    var QUART_IN;
    var QUART_OUT;
    var QUART_INOUT;
    var QUINT_IN;
    var QUINT_OUT;
    var QUINT_INOUT;
    var SMOOTHSTEP_IN;
    var SMOOTHSTEP_OUT;
    var SMOOTHSTEP_INOUT;
    var SMOOTHERSTEP_IN;
    var SMOOTHERSTEP_OUT;
    var SMOOTHERSTEP_INOUT;
    var BOUNCE_IN;
    var BOUNCE_OUT;
    var BOUNCE_INOUT;
    var CIRC_IN;
    var CIRC_OUT;
    var CIRC_INOUT;
    var EXPO_IN;
    var EXPO_OUT;
    var EXPO_INOUT;
    var BACK_IN;
    var BACK_OUT;
    var BACK_INOUT;
    var ELASTIC_IN;
    var ELASTIC_OUT;
    var ELASTIC_INOUT;
}

private typedef CitroTweenProps = {
    /**
     * Common variable to use from CitroObject
     * 
     * @see enum abstract CitroEase
     */
    variableToUse:CitroObjVar,

    /**
     * The destination for the float number to use.
     */
    destination:Float,

    /**
     * Should not be used.
     */
    ?oldVar:Float
}

private typedef CitroTweenArray = {
    variable:CitroObject,
    props:Array<CitroTweenProps>,
    length:Float,
    elapsed:Float,
    onComplete:Void->Void,
    ease:CitroEase,
    isState:Bool
}

@:cppInclude("3ds.h")
@:cppInclude("citro_CitroInit.h")

/**
 * Class for doing tweens and such.
 */
class CitroTween {
    public static var cta:Array<CitroTweenArray> = [];

    /**
     * Creates and starts a new tween from object.
     * @param object Object to use as.
     * @param props Which props to use? Can be an array with multiple stuff.
     * @param duration How long in seconds do you want it to tween for?
     * @param easing The style of easing to use as.
     * @param onComplete Callback function for tween completion.
     */
    public static function tween(object:CitroObject, props:Array<CitroTweenProps>, duration:Float = 1, easing:CitroEase = LINEAR, onComplete:Void->Void = null) {
        if (untyped __cpp__('onComplete == nullptr')) {
            onComplete = function() {};
        }

        var propStates:Array<CitroTweenProps> = [];
        for (prop in props) {
            propStates.push({
                variableToUse: prop.variableToUse,
                destination: prop.destination,
                oldVar: switch (prop.variableToUse) {
                    case X: object.x;
                    case Y: object.y;
                    case WIDTH: object.width;
                    case HEIGHT: object.height;
                    case ANGLE: object.angle;
                    case ALPHA: object.alpha;
                    case SCALE_X: object.scale.x;
                    case SCALE_Y: object.scale.y;
                }
            });
        }

        cta.push({
            variable: object,
            props: propStates,
            elapsed: 0,
            length: duration * 1000,
            onComplete: untyped __cpp__('onComplete == nullptr') ? function() {} : onComplete,
            ease: easing,
            isState: untyped __cpp__('citro::CitroInit::subState == nullptr || citro::CitroInit::subState == NULL')
        });
    }

    /**
     * Updates all tweens, should not be used.
     * @param delta Time since last frame in milliseconds.
     */
    public static function update(delta:Int) {
        var i:Int = cta.length-1;
        if (i == -1) {
            return;
        }

        while (i != -1) {
            var spr = cta[i];

            if (spr.isState != untyped __cpp__('(citro::CitroInit::subState == nullptr || citro::CitroInit::subState == NULL)')) {
                i--;
                continue;
            }

            spr.elapsed += delta;
            var progress:Float = spr.elapsed / spr.length;
            if (progress > 1) progress = 1;

            for (prop in spr.props) {
                final res:Float = CitroMath.lerp(prop.oldVar, prop.destination, applyEase(spr.ease, progress));
                switch(prop.variableToUse) {
                    case ALPHA: spr.variable.alpha = res;
                    case ANGLE: spr.variable.angle = res;
                    case HEIGHT: spr.variable.height = res;
                    case SCALE_X: spr.variable.scale.x = res;
                    case SCALE_Y: spr.variable.scale.y = res;
                    case WIDTH: spr.variable.width = res;
                    case X: spr.variable.x = res;
                    case Y: spr.variable.y = res;
                }
            }

            if (progress >= 1) {
                if (untyped __cpp__('spr->onComplete != NULL && spr->onComplete != nullptr')) {
                    spr.onComplete();
                }
                cta.splice(i, 1);
            }

            i--;
        }
    }

    /**
     * Cancels any tweens provided from the object argument.
     * @param object Object to cancel tweens.
     */
    public static function cancelTweensFrom(object:CitroObject) {
        var i:Int = cta.length-1;
        while (i != -1) {
            if (cta[i].variable == object) cta.splice(i, 1);
            i--;
        }
    }

    static function smoothStepInOut(t:Float):Float {
        return t * t * (t * -2 + 3);
    }

    static function smootherStepInOut(t:Float):Float {
		return t * t * t * (t * (t * 6 - 15) + 10);
	}

    static var B1:Float = 1 / 2.75;
	static var B2:Float = 2 / 2.75;
	static var B3:Float = 1.5 / 2.75;
	static var B4:Float = 2.5 / 2.75;
	static var B5:Float = 2.25 / 2.75;
	static var B6:Float = 2.625 / 2.75;
    static var ELASTIC_AMPLITUDE:Float = 1;
	static var ELASTIC_PERIOD:Float = 0.4;

    static function bounceOut(t:Float):Float {
		if (t < B1) return 7.5625 * t * t;
		if (t < B2) return 7.5625 * (t - B3) * (t - B3) + .75;
		if (t < B4) return 7.5625 * (t - B5) * (t - B5) + .9375;
		return 7.5625 * (t - B6) * (t - B6) + .984375;
	}

    static function backInOut(t:Float):Float {
		t *= 2;
		if (t < 1) return t * t * (2.70158 * t - 1.70158) / 2;
		t--;
		return (1 - (--t) * (t) * (-2.70158 * t - 1.70158)) / 2 + .5;
	}

    static function applyEase(ease:CitroEase, t:Float):Float {
        return switch(ease) {
            case LINEAR: t;

            case SINE_IN: 1 - Math.cos((t * Math.PI) / 2);
            case SINE_OUT: Math.sin((t * Math.PI) / 2);
            case SINE_INOUT: -(Math.cos(Math.PI * t) - 1) / 2;

            case QUAD_IN: t * t;
            case QUAD_OUT: -t * (t - 2);
            case QUAD_INOUT: t <= .5 ? t * t * 2 : 1 - (t--) * t * 2;

            case CUBE_IN: t * t * t;
            case CUBE_OUT: 1 + (t--) * t * t;
            case CUBE_INOUT: t <= .5 ? t * t * t * 4 : 1 + (t--) * t * t * 4;
            
            case QUART_IN: t * t * t * t;
            case QUART_OUT: 1 - (t -= 1) * t * t * t;
            case QUART_INOUT: t <= .5 ? t * t * t * t * 8 : (1 - (t = t * 2 - 2) * t * t * t) / 2 + .5;
            
            case QUINT_IN: t * t * t * t * t;
            case QUINT_OUT: (t = t - 1) * t * t * t * t + 1;
            case QUINT_INOUT: ((t *= 2) < 1) ? (t * t * t * t * t) / 2 : ((t -= 2) * t * t * t * t + 2) / 2;
            
            case SMOOTHSTEP_IN: 2 * smoothStepInOut(t / 2);
            case SMOOTHSTEP_OUT: 2 * smoothStepInOut(t / 2 + 0.5) - 1;
            case SMOOTHSTEP_INOUT: smoothStepInOut(t);
            
            case SMOOTHERSTEP_IN: 2 * smootherStepInOut(t / 2);
            case SMOOTHERSTEP_OUT: 2 * smootherStepInOut(t / 2 + 0.5) - 1;
            case SMOOTHERSTEP_INOUT: smootherStepInOut(t);

            case BOUNCE_IN: 1 - bounceOut(1 - t);
            case BOUNCE_OUT: bounceOut(t);
            case BOUNCE_INOUT: t < 0.5 ? (1 - bounceOut(1 - 2 * t)) / 2 : (1 + bounceOut(2 * t - 1)) / 2;
            
            case CIRC_IN: -(Math.sqrt(1 - t * t) - 1);
            case CIRC_OUT: Math.sqrt(1 - (t - 1) * (t - 1));
            case CIRC_INOUT: t <= .5 ? (Math.sqrt(1 - t * t * 4) - 1) / -2 : (Math.sqrt(1 - (t * 2 - 2) * (t * 2 - 2)) + 1) / 2;
            
            case EXPO_IN: Math.pow(2, 10 * (t - 1));
            case EXPO_OUT: -Math.pow(2, -10 * t) + 1;
            case EXPO_INOUT: t < .5 ? Math.pow(2, 10 * (t * 2 - 1)) / 2 : (-Math.pow(2, -10 * (t * 2 - 1)) + 2) / 2;
            
            case BACK_IN: t * t * (2.70158 * t - 1.70158);
            case BACK_OUT: 1 - (--t) * (t) * (-2.70158 * t - 1.70158);
            case BACK_INOUT: backInOut(t);
            
            case ELASTIC_IN: -(ELASTIC_AMPLITUDE * Math.pow(2, 10 * (t -= 1)) * Math.sin((t - (ELASTIC_PERIOD / (2 * Math.PI) * Math.asin(1 / ELASTIC_AMPLITUDE))) * (2 * Math.PI) / ELASTIC_PERIOD));
            case ELASTIC_OUT: (ELASTIC_AMPLITUDE * Math.pow(2, -10 * t) * Math.sin((t - (ELASTIC_PERIOD / (2 * Math.PI) * Math.asin(1 / ELASTIC_AMPLITUDE))) * (2 * Math.PI) / ELASTIC_PERIOD) + 1);
            case ELASTIC_INOUT: t < 0.5 ? -0.5 * (Math.pow(2, 10 * (t -= 0.5)) * Math.sin((t - (ELASTIC_PERIOD / 4)) * (2 * Math.PI) / ELASTIC_PERIOD)) : Math.pow(2, -10 * (t -= 0.5)) * Math.sin((t - (ELASTIC_PERIOD / 4)) * (2 * Math.PI) / ELASTIC_PERIOD) * 0.5 + 1;
            
            default: t;
        }
    }
}