package citro.math;

import cxx.num.UInt32;

@:cppInclude("citro2d.h")

/**
 * Class that uses a randomizer by using stdlib and stuff.
 * 
 * Do not use this class, instead use `CitroG.random`.
 */
class CitroRandom {
    /**
     * Returns a pseudorandom integer between min and max.
     * @param min The minimum value that should be returned. 1 by default.
     * @param max The maximum value that should be returned. 2,147,483,647 by default.
     * @return A Random number depending on the arguments.
     */
    public function integer(from:Int = 1, to:Int = 2147483647):Int {
        return from + Std.random(to + 1 - from);
    }

    /**
     * Returns a pseudorandom float value between Min (inclusive) and Max (exclusive).
     * @param min The minimum value that should be returned. 1 by default.
     * @param max The maximum value that should be returned. 2,147,483,647 by default.
     * @return A Random number depending on the arguments.
     */
    public function floating(from:Float = 1, to:Float = 2147483647):Float {
        return from + (Math.random() * (to - from));
    }

    /**
     * Returns true or false based on the chance value (default 50%).
     * 
     * For example if you wanted a player to have a 30.5% chance of getting a bonus, call `boolean(30.5)` - true means the chance passed, false means it failed.
     * @param chance The chance of receiving the value. Should be given as a number between 0 and 100 (effectively 0% to 100%). 50 by default.
     * @return Whether the roll passed or not.
     */
    public function boolean(chance:Float = 50):Bool {
        return floating(0, CitroMath.clamp(chance, 0, 100)) < chance;
    }

    /**
     * Returns a random color by ranging through 0xFF000000 (black) to 0xFFFFFFFF (white).
     */
    public function color():UInt32 {
        return untyped __cpp__('C2D_Color32(integer(0, 255), integer(0, 255), integer(0, 255), 255)');
    }

    public function new() {};
}