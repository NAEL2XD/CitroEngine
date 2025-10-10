package citro.object;

import citro.object.CitroSprite;
import haxe3ds.stdutil.FSUtil;

using StringTools;

private typedef CitroAnimateHeader = {
    var frameX:Float;
    var frameY:Float;
    var sprite:CitroSprite;
}

/**
 * A class for animation purpose.
 */
class CitroAnimate extends CitroObject {
    var timeLeft:Int = 0;
    var sprites:Map<String, CitroAnimateHeader> = [];

    /**
     * The fps for this animation to use.
     */
    public var fps:Float = 24;

    /**
     * The current frame for this animation playing.
     */
    public var frame:Int = 0;

    /**
     * The current playing animation name that's gonna be used.
     */
    public var animPlay:String = "";

    /**
     * Constructs this sprite.
     * @param craFile Path to the `.cea` (Citro Engine Animate) file to parse, `romfs:/` included.
     * @param defaultAnim The default animation that's going to be used.
     */
    public function new(ceaFile:String, defaultAnim:String = "idle") {
        super();

        final file = FSUtil.readFile('romfs:/${ceaFile}');
        ceaFile = ceaFile.substr(0, ceaFile.lastIndexOf("/"));
        if (file != "") {
            var i:Int = 0;
            var old:Array<String> = [];
            for (j => line in file.split("\n")) {
                var row = line.split("?");
                if (row.length < 3) break;
                row[3] = row[3].trim();

                if (!old.join(" ").contains(row[3])) {
                    old.push(row[3]);
                    i = -1;
                }
                i++;

                var sprite = new CitroSprite();
                sprite.loadGraphic('$ceaFile/${row[0]}');
                sprites.set('${row[3]}-$i', {
                    frameX: Std.parseFloat(row[1]),
                    frameY: Std.parseFloat(row[2]),
                    sprite: sprite
                });
            }
        }

        play(defaultAnim);
    }

    /**
     * Plays a new animation that's found in the sprite's map.
     * @param animation Animation name to play.
     */
    public function play(animation:String):Bool {
        if (isDestroyed) {
            return false;
        }
        
        var old = frame;
        frame = 0;

        for (key in sprites.keys()) {
            if (key == '${animation}-0') {
                timeLeft = Std.int(1000 / fps);
                animPlay = animation;
                return true;
            }
        }

        frame = old;
        return false;
    }

    function format() {
        return '${animPlay}-$frame';
    }

    override function update(delta:Int):Bool {
        if (isDestroyed) {
            return false;
        }

        timeLeft -= delta;
        if (timeLeft < 1) {
            timeLeft = Std.int(1000 / fps);
            frame++;
            if (!sprites.exists(format())) {
                frame--;
            } else {
                var header = sprites.get(format()).sprite;
                width = header.width;
                height = header.height;
            }
        }

        if (sprites.exists(format()) && visible) {
            var header = sprites.get(format());
            var sprite = header.sprite;
            sprite.acceleration = acceleration;
            sprite.alpha  = alpha;
            sprite.angle  = angle;
            sprite.bottom = bottom;
            sprite.color  = color;
            sprite.factor = factor;
            sprite.scale  = scale;
            sprite.x = x - (header.frameX * scale.x);
            sprite.y = y - (header.frameY * scale.y);
            return sprite.update(delta);
        }

        return false;
    }

    override function destroy() {
        for (key in sprites) {
            key.sprite.destroy();
        }

        super.destroy();
        sprites = null;
    }
}