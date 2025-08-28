package citro.backend;

import citro.math.CitroMath;

/**
 * A backend for camera only, useful if you wanna make a camera like view.
 * 
 * @since 1.1.0
 */
class CitroCamera {
    /**
     * Constructor for making the camera
     */
    public function new() {}

    /**
     * Don't use this.
     */
    public var _xPtr(default, null):Float = 0;
    public var _yPtr(default, null):Float = 0;
    public var _curZm(default, null):Float = 1;
    var curX:Float = 0;
    var curY:Float = 0;

    /**
     * Current X (Horizontal) position for the camera.
     */
    public var x:Float = 0;

    /**
     * Current Y (Vertical) position for the camera.
     */
    public var y:Float = 0;

    /**
     * Per update lerping to update X and Y's Position.
     */
    public var lerp:Float = 0.5;

    /**
     * Current zoom usage.
     */
    public var zoom:Float = 1;

    /**
     * Updates the camera's position needed so that sprites can move stuff around.
     */
    public function update() {
        _curZm = CitroMath.lerp(_curZm, zoom, lerp);
        curX = CitroMath.lerp(curX, x * (_curZm / 2), lerp);
        curY = CitroMath.lerp(curY, y * (_curZm / 2), lerp);
        _xPtr = curX * _curZm;
        _yPtr = curY * _curZm;
    }
}