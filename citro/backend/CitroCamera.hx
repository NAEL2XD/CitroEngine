package citro.backend;

import citro.object.CitroObject;
import citro.math.CitroMath;

/**
 * A backend for camera only, useful if you wanna make a camera like view.
 * 
 * @since 1.1.0
 */
@:cppInclude("citro2d.h")
@:cppInclude("citro_CitroInit.h")
class CitroCamera {
    /**
     * Don't use this.
     */
    var members:Array<CitroObject> = [];
    var _xPtr(default, null):Float = 0;
    var _yPtr(default, null):Float = 0;
    var _curZm(default, null):Float = 1;
    var curX:Float = 0;
    var curY:Float = 0;
    var bottomCam:Bool = false;

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
     * Constructor for making the camera.
     * @param bottom Whetever or not the camera positions at the bottom.
     */
    public function new(bottom:Bool) {
        bottomCam = bottom;
    }

    /**
     * Updates the camera's position needed so that members can move stuff and draw around in camera.
     * @param delta Delta time in CitroState's delta arg.
     */
    public function update(delta:Int) {
        untyped __cpp__("C2D_SceneBegin(this->bottomCam ? bottomScreen : topScreen)");
        final scX:Float = bottomCam ? 160 : 200;

        _curZm = CitroMath.lerp(_curZm, zoom, lerp);
        curX = CitroMath.lerp(curX, x, lerp);
        curY = CitroMath.lerp(curY, y, lerp);
        _xPtr = curX - (scX * _curZm);
        _yPtr = curY - (120 * _curZm);

        var i:Int = 0;
        for (spr in members) {
            if (spr.isDestroyed) {
                members.splice(i, 1);
                continue;
            }

            final oldX:Float = spr.x;
            final oldY:Float = spr.y;
            final oldSX:Float = spr.scale.x;
            final oldSY:Float = spr.scale.y;

            spr.scale.x *= _curZm;
            spr.scale.y *= _curZm;
            spr.x = (oldX + curX - scX) * _curZm + scX;
            spr.y = (oldY + curY - 120) * _curZm + 120;
            
            spr.update(delta);
            
            spr.x = oldX;
            spr.y = oldY;
            spr.scale.x = oldSX;
            spr.scale.y = oldSY;

            i++;
        }
    }

    /**
     * Adds a CitroObject to camera and displays it every frame if you call `update`.
     * @param member An object to add as.
     */
    public function add(member:CitroObject) {
        members.push(member);
    }

    /**
     * Inserts a CitroObject to a layer index specified.
     * @param index Layer number to insert from.
     * @param member An object to insert as.
     */
    public function insert(index:Int, member:CitroObject) {
        members.insert(index, member);
    }

    /**
     * Will destroy every sprite from camera and clean memory, Only call this on `override function destroy` state function.
     */
    public function destroy() {
        for (member in members) {
            member.destroy();
        }

        members = [];
    }
}